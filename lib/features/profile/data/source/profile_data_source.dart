import 'package:receta_ya/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDataSource {
  Future<void> createProfile(Profile profile);
  Future<Profile?> getProfile(String userId);
}

class ProfileDataSourceImpl extends ProfileDataSource {
  @override
  Future<void> createProfile(Profile profile) async {
    try {
      await Supabase.instance.client.from("users").insert({
        'user_id': profile.id,
        'name': profile.name,
        'avatar_url': null, // Por ahora null, se puede actualizar después
        'created_at': profile.createdAt.toIso8601String(),
      });
      print('Usuario creado exitosamente en la tabla users con ID: ${profile.id}');
    } catch (e) {
      print('Error al crear usuario en tabla users: $e');
      throw Exception('No se pudo crear el usuario en la base de datos: $e');
    }
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .single();

      // Obtener datos del usuario autenticado para el email
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      return Profile.fromAuthAndUserData(
        id: response['user_id'] as String,
        email: currentUser?.email ?? '',
        name: response['name'] as String,
        avatarUrl: response['avatar_url'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      print('Error al obtener perfil del usuario: $e');
      return null;
    }
  }
}
