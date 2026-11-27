import '../core/supabase_client.dart';

/// Exact replica of `src/services/profileService.js`
class ProfileService {
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  static Future<Map<String, dynamic>> createProfile({
    required String id,
    required String fullName,
    required String whatsappNumber,
    required String age,
    required String gender,
    required String address,
  }) async {
    final data = await supabase
        .from('profiles')
        .insert({
          'id': id,
          'full_name': fullName,
          'whatsapp_number': whatsappNumber,
          'age': int.tryParse(age) ?? 0,
          'gender': gender,
          'address': address,
          'role': 'user_iqlab',
        })
        .select()
        .single();
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String fullName,
    required String whatsappNumber,
    required String age,
    required String gender,
    required String address,
  }) async {
    final data = await supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'whatsapp_number': whatsappNumber,
          'age': int.tryParse(age) ?? 0,
          'gender': gender,
          'address': address,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();
    return data;
  }

  static Future<bool> updatePushToken(String userId, String token) async {
    await supabase.from('profiles').update({
      'expo_push_token': token,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
    return true;
  }
}

