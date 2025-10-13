import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/auth/data/repository/user_repository_impl.dart';
import 'package:receta_ya/features/auth/domain/repository/auth_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository = UserRepositoryImpl();

  Future<void> execute(Profile profile, String password) {
    return repository.registerUser(profile, password);
  }
}
