import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/profile/data/repository/profile_repository_impl.dart';
import 'package:receta_ya/features/profile/domain/repository/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepositoryImpl();

  Future<void> execute(Profile profile) {
    return repository.createProfile(profile);
  }
}
