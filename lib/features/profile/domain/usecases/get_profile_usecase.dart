import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/profile/data/repository/profile_repository_impl.dart';
import 'package:receta_ya/features/profile/domain/repository/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({ProfileRepository? repository})
      : repository = repository ?? ProfileRepositoryImpl();

  Future<Profile?> execute(String userId) {
    return repository.getProfile(userId);
  }
}
