import 'package:receta_ya/features/profile/data/repository/profile_repository_impl.dart';
import 'package:receta_ya/features/profile/domain/repository/profile_repository.dart';

class UpdateOnboardingDataUseCase {
  final ProfileRepository repository;

  UpdateOnboardingDataUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepositoryImpl();

  Future<void> execute(
    String userId, {
    String? cookingSkill,
    List<String>? cookingGoals,
    int? typicalServings,
    String? cookingTimePreference,
  }) {
    return repository.updateOnboardingData(
      userId,
      cookingSkill: cookingSkill,
      cookingGoals: cookingGoals,
      typicalServings: typicalServings,
      cookingTimePreference: cookingTimePreference,
    );
  }
}
