import 'package:supabase_flutter/supabase_flutter.dart';

class RequestPasswordResetUseCase {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> execute(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'recetaya://reset-password',
      );
    } catch (e) {
      throw Exception('Error al solicitar restablecimiento de contraseña: $e');
    }
  }
}
