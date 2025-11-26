import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordUseCase {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> execute(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Error al actualizar contraseña: $e');
    }
  }
}
