import 'package:receta_ya/domain/model/profile.dart';

abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);
  Future<Profile?> getProfile(String userId);
  Future<void> updateOnboardingData(
    String userId, {
    String? cookingSkill,
    List<String>? cookingGoals,
    int? typicalServings,
    String? cookingTimePreference,
  });
  Future<void> updateProfile(Profile profile);
}
