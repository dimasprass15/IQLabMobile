import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Encrypted session storage for mobile devices (Android Keystore / iOS Keychain),
/// matching `SecureStoreAdapter` in `src/lib/supabase.js`.
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();

  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'supabase_persist_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return await _storage.containsKey(key: _sessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: _sessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _sessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _sessionKey, value: persistSessionString);
  }
}

class SupabaseClientManager {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final supabaseUrl = dotenv.env['EXPO_PUBLIC_SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY'] ?? '';

    final useSecureStorage = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: true,
        localStorage: useSecureStorage ? const SecureLocalStorage() : null,
      ),
    );
    _isInitialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}

SupabaseClient get supabase => SupabaseClientManager.client;
