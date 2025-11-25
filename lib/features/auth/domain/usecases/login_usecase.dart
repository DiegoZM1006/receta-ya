import 'package:receta_ya/features/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({AuthRepository? repository})
    : repository = repository ?? AuthRepositoryImpl();

  Future<void> execute(String email, String password) {
    return repository.signIn(email, password);
  }
}
