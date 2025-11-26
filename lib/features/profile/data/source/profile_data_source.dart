import 'package:receta_ya/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDataSource {
  Future<void> createProfile(Profile profile);
  Future<Profile?> getProfile(String userId);
  Future<void> updateOnboardingData(
    String userId, {
    String? cookingSkill,
    List<String>? cookingGoals,
    int? typicalServings,
    String? cookingTimePreference,
  });
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
      print(
        'Usuario creado exitosamente en la tabla users con ID: ${profile.id}',
      );
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
        role: response['role'] as String?,
      );
    } catch (e) {
      print('Error al obtener perfil del usuario: $e');
      return null;
    }
  }

  @override
  Future<void> updateOnboardingData(
    String userId, {
    String? cookingSkill,
    List<String>? cookingGoals,
    int? typicalServings,
    String? cookingTimePreference,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (cookingSkill != null) data['cooking_skill'] = cookingSkill;
      if (cookingGoals != null) data['cooking_goals'] = cookingGoals;
      if (typicalServings != null) data['typical_servings'] = typicalServings;
      if (cookingTimePreference != null)
        data['cooking_time_preference'] = cookingTimePreference;

      if (data.isEmpty) return;

      await Supabase.instance.client
          .from('users')
          .update(data)
          .eq('user_id', userId);

      print('Onboarding data updated for user $userId');
    } catch (e) {
      print('Error updating onboarding data: $e');
      throw Exception('Error updating onboarding data: $e');
    }
  }
}
