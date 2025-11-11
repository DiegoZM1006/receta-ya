import 'package:receta_ya/domain/model/profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;

  LoadProfile(this.userId);
}

class UpdateProfileData extends ProfileEvent {
  final Profile profile;

  UpdateProfileData(this.profile);
}

class UpdateOnboardingData extends ProfileEvent {
  final String userId;
  final String? cookingSkill;
  final List<String>? cookingGoals;
  final int? typicalServings;
  final String? cookingTimePreference;

  UpdateOnboardingData({
    required this.userId,
    this.cookingSkill,
    this.cookingGoals,
    this.typicalServings,
    this.cookingTimePreference,
  });
}
