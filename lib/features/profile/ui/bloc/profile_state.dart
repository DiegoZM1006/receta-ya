import 'package:receta_ya/domain/model/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final Profile profile;

  ProfileUpdated(this.profile);
}

class OnboardingDataUpdated extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}
