import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'schema.dart';
import 'supabase_connector.dart';

/// The phone's local database. The UI always reads from here, so the app
/// works without internet. Moves to a Riverpod provider when features start.
late final PowerSyncDatabase db;

Future<void> openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  db = PowerSyncDatabase(schema: schema, path: join(dir.path, 'ojie.db'));
  await db.initialize();

  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) {
    await db.connect(connector: SupabaseConnector());
  }

  // Start syncing on sign in. On sign out, wipe the local copy so the next
  // person on this phone never sees the previous user's data.
  auth.onAuthStateChange.listen((data) async {
    switch (data.event) {
      case AuthChangeEvent.signedIn:
        await db.connect(connector: SupabaseConnector());
      case AuthChangeEvent.signedOut:
        await db.disconnectAndClear();
      default:
        break;
    }
  });
}
