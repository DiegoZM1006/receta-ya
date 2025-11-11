import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receta_ya/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:receta_ya/features/profile/domain/usecases/update_onboarding_data_usecase.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_event.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateOnboardingDataUseCase updateOnboardingDataUseCase;

  ProfileBloc({
    GetProfileUseCase? getProfileUseCase,
    UpdateOnboardingDataUseCase? updateOnboardingDataUseCase,
  })  : getProfileUseCase = getProfileUseCase ?? GetProfileUseCase(),
        updateOnboardingDataUseCase =
            updateOnboardingDataUseCase ?? UpdateOnboardingDataUseCase(),
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateOnboardingData>(_onUpdateOnboardingData);
    on<UpdateProfileData>(_onUpdateProfileData);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase.execute(event.userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('No se pudo cargar el perfil'));
      }
    } catch (e) {
      emit(ProfileError('Error al cargar el perfil: $e'));
    }
  }

  Future<void> _onUpdateOnboardingData(
    UpdateOnboardingData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      await updateOnboardingDataUseCase.execute(
        event.userId,
        cookingSkill: event.cookingSkill,
        cookingGoals: event.cookingGoals,
        typicalServings: event.typicalServings,
        cookingTimePreference: event.cookingTimePreference,
      );
      emit(OnboardingDataUpdated());
      // Recargar el perfil después de actualizar
      add(LoadProfile(event.userId));
    } catch (e) {
      emit(ProfileError('Error al actualizar datos de onboarding: $e'));
    }
  }

  Future<void> _onUpdateProfileData(
    UpdateProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      // Aquí puedes implementar la lógica para actualizar el perfil
      // Por ahora solo emitimos el estado actualizado
      emit(ProfileUpdated(event.profile));
    } catch (e) {
      emit(ProfileError('Error al actualizar el perfil: $e'));
    }
  }
}
