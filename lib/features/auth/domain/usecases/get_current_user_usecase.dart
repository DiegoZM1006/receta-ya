import 'package:receta_ya/features/auth/domain/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({AuthRepository? repository})
    : repository = repository ?? AuthRepositoryImpl();

  Future<String?> execute() {
    return repository.getCurrentUserId();
  }
}
