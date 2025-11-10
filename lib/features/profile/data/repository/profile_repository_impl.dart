import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/profile/data/source/profile_data_source.dart';
import 'package:receta_ya/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource profileDataSource;

  ProfileRepositoryImpl({ProfileDataSource? dataSource})
      : profileDataSource = dataSource ?? ProfileDataSourceImpl();

  @override
  Future<void> createProfile(Profile profile) async {
    try {
      await profileDataSource.createProfile(profile);
    } catch (e) {
      print('Error en ProfileRepository al crear perfil: $e');
      rethrow;
    }
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      return await profileDataSource.getProfile(userId);
    } catch (e) {
      print('Error en ProfileRepository al obtener perfil: $e');
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
      await profileDataSource.updateOnboardingData(
        userId,
        cookingSkill: cookingSkill,
        cookingGoals: cookingGoals,
        typicalServings: typicalServings,
        cookingTimePreference: cookingTimePreference,
      );
    } catch (e) {
      print('Error en ProfileRepository al actualizar datos de onboarding: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      // Aquí puedes implementar la lógica para actualizar el perfil completo
      // Por ahora, puedes dejarlo como placeholder
      throw UnimplementedError('updateProfile aún no implementado');
    } catch (e) {
      print('Error en ProfileRepository al actualizar perfil: $e');
      rethrow;
    }
  }
}
