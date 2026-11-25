import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Connects the local PowerSync database to Supabase.
///
/// Downloads come from the PowerSync service. Uploads (changes made on the
/// phone) are sent straight to Supabase here, where RLS checks them.
class SupabaseConnector extends PowerSyncBackendConnector {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    return PowerSyncCredentials(
      endpoint: Env.powerSyncUrl,
      token: session.accessToken,
      userId: session.user.id,
      expiresAt:
          expiresAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
    );
  }

  @override
  void invalidateCredentials() {
    // Ask Supabase for a fresh token; PowerSync calls fetchCredentials after.
    _client.auth.refreshSession().ignore();
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    for (final entry in transaction.crud) {
      try {
        await _upload(entry);
      } on PostgrestException catch (error, stack) {
        if (error.code == _uniqueViolation && entry.op == UpdateType.put) {
          // Already on the server from an earlier attempt: no double entry.
          continue;
        }
        if (_isPermanentError(error.code)) {
          // The server will never accept this change (bad data or not
          // allowed). Report it and drop it, so it does not block every other
          // change behind it forever.
          debugPrint('Upload rejected for ${entry.table}/${entry.id}: $error');
          await FirebaseCrashlytics.instance.recordError(
            error,
            stack,
            reason: 'PowerSync upload rejected for ${entry.table}',
          );
          continue;
        }
        // Network or server hiccup: PowerSync retries the whole transaction.
        rethrow;
      }
    }
    await transaction.complete();
  }

  Future<void> _upload(CrudEntry entry) async {
    final table = _client.from(entry.table);
    switch (entry.op) {
      case UpdateType.put:
        await table.insert({...?entry.opData, 'id': entry.id});
      case UpdateType.patch:
        await table.update(entry.opData!).eq('id', entry.id);
      case UpdateType.delete:
        await table.delete().eq('id', entry.id);
    }
  }

  static const _uniqueViolation = '23505';

  /// Postgres codes that will not succeed on retry: data errors (22xxx),
  /// constraint errors (23xxx) and "not allowed" (42501, RLS).
  static bool _isPermanentError(String? code) {
    if (code == null) return false;
    return code.startsWith('22') || code.startsWith('23') || code == '42501';
  }
}
