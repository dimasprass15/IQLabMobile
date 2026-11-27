import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';

/// Exact replica of `src/services/authService.js`
class AuthService {
  static bool _googleInitialized = false;

  static Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    final webClientId = dotenv.env['EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID'];
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
    );
    _googleInitialized = true;
  }

  /// Google OAuth Sign In:
  /// 1. Tries Native Google Sign-In (`GoogleSignIn.instance.authenticate()`)
  /// 2. Falls back to Browser OAuth flow (`signInWithOAuth`) if native is unavailable/fails
  static Future<void> signInWithGoogle() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        await _ensureGoogleInitialized();
        if (GoogleSignIn.instance.supportsAuthenticate()) {
          final account = await GoogleSignIn.instance.authenticate();
          final idToken = account.authentication.idToken;
          if (idToken != null) {
            await supabase.auth.signInWithIdToken(
              provider: OAuthProvider.google,
              idToken: idToken,
            );
            return;
          }
        }
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return;
        }
        // Fall through to OAuth browser fallback
      } catch (_) {
        // Fall through to OAuth browser fallback
      }
    }

    // Browser OAuth fallback (matching authService.js lines 40-71)
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'iqlab://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<AuthResponse> signInWithEmail(
      String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    Map<String, dynamic>? metadata,
  ) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  static Future<void> signOut() async {
    try {
      if (!kIsWeb && _googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
    await supabase.auth.signOut();
  }

  static Session? getSession() {
    return supabase.auth.currentSession;
  }
}

