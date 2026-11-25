import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';

/// Sign in and out with Google, using Supabase as the account system.
class AuthRepository {
  bool _googleReady = false;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  Future<void> _ensureGoogleReady() async {
    if (_googleReady) return;
    // The web client ID makes Google return an ID token that Supabase accepts.
    await GoogleSignIn.instance.initialize(
      serverClientId: Env.googleWebClientId,
    );
    _googleReady = true;
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleReady();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google did not return an ID token.');
    }
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await _ensureGoogleReady();
    await GoogleSignIn.instance.signOut();
    await Supabase.instance.client.auth.signOut();
  }
}
