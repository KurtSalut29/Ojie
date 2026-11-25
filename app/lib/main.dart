import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/database/database.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Send uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final missing = Env.missing;
  if (missing.isNotEmpty) {
    runApp(_MissingSettingsApp(missing));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  await openDatabase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder until the Release 1 screens are built.
    return const MaterialApp(
      title: 'Ojie',
      home: Scaffold(body: Center(child: Text('Ojie'))),
    );
  }
}

/// Shown when the app was started without `--dart-define-from-file=../.env`.
class _MissingSettingsApp extends StatelessWidget {
  const _MissingSettingsApp(this.missing);

  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Missing settings: ${missing.join(', ')}\n\n'
              'Run with: flutter run --dart-define-from-file=../.env',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
