// TEMPORARY: proves every tool is connected (setup guide, Step 9).
// Delete this folder once all four tests pass.

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:powersync/powersync.dart' show SyncStatus;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/database/database.dart';
import '../features/auth/data/auth_repository.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final _auth = AuthRepository();
  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<RemoteMessage> _pushSub;
  bool _busy = false;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => setState(() {}),
    );
    // While the app is open, Android does not show the notification itself,
    // so show it on screen instead.
    _pushSub = FirebaseMessaging.onMessage.listen((message) {
      _show('Push received: ${message.notification?.title ?? '(no title)'}');
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _pushSub.cancel();
    super.dispose();
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _show('Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveTest() async {
    final user = _auth.currentUser!;
    final now = DateTime.now();
    await db.execute(
      'INSERT INTO connection_checks (id, user_id, note, created_at) '
      'VALUES (uuid(), ?, ?, ?)',
      [
        user.id,
        'Test from phone at ${TimeOfDay.fromDateTime(now).format(context)}',
        now.toUtc().toIso8601String(),
      ],
    );
    _show('Saved on the phone.');
  }

  Future<void> _getPushToken() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _show('Notifications are blocked. Allow them in phone Settings.');
      return;
    }
    // The Firebase console "Send test message" needs this token, so the
    // deprecated call is fine for this temporary test.
    // ignore: deprecated_member_use
    final token = await FirebaseMessaging.instance.getToken();
    setState(() => _fcmToken = token);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Ojie connection test')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: '1. Google login',
              children: [
                Text(
                  user == null ? 'Not signed in' : 'Signed in: ${user.email}',
                ),
                const SizedBox(height: 8),
                if (user == null)
                  FilledButton(
                    onPressed: () => _run(_auth.signInWithGoogle),
                    child: const Text('Sign in with Google'),
                  )
                else
                  OutlinedButton(
                    onPressed: () => _run(_auth.signOut),
                    child: const Text('Sign out'),
                  ),
              ],
            ),
            _Section(
              title: '2. Offline save and sync',
              children: [
                const Text(
                  'Turn on airplane mode, tap Save test, then turn airplane '
                  'mode off. The row should show up in Supabase.',
                ),
                const SizedBox(height: 8),
                const _SyncStatusLine(),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: user == null ? null : () => _run(_saveTest),
                  child: const Text('Save test'),
                ),
                const SizedBox(height: 8),
                const _SavedRows(),
              ],
            ),
            _Section(
              title: '3. Push notification',
              children: [
                FilledButton(
                  onPressed: () => _run(_getPushToken),
                  child: const Text('Get push token'),
                ),
                if (_fcmToken != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    _fcmToken!,
                    style: const TextStyle(fontSize: 11),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _fcmToken!));
                      _show('Token copied.');
                    },
                    child: const Text('Copy token'),
                  ),
                ],
              ],
            ),
            _Section(
              title: '4. Crash report',
              children: [
                const Text(
                  'The app will close. Open it again so the report is sent.',
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => FirebaseCrashlytics.instance.crash(),
                  child: const Text('Test crash'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SyncStatusLine extends StatelessWidget {
  const _SyncStatusLine();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: db.statusStream,
      initialData: db.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data!;
        final state =
            status.connected
                ? 'Online'
                : status.connecting
                ? 'Connecting...'
                : 'Offline';
        final error = status.anyError;
        return Text(
          'Sync: $state'
          '${status.uploading ? ' · uploading' : ''}'
          '${status.downloading ? ' · downloading' : ''}'
          '${status.hasSynced == true ? ' · synced' : ''}'
          '${error != null ? '\nError: $error' : ''}',
        );
      },
    );
  }
}

class _SavedRows extends StatelessWidget {
  const _SavedRows();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.watch(
        'SELECT note FROM connection_checks ORDER BY created_at DESC',
      ),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rows on this phone: ${rows.length}'),
            for (final row in rows.take(5)) Text('• ${row['note']}'),
          ],
        );
      },
    );
  }
}
