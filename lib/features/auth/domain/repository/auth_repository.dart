import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/auth/data/source/auth_data_source.dart';

abstract class UserRepository {
  Future<void> registerUser(Profile profile, String password);
}

abstract class AuthRepository {
  Future<String?> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<String?> getCurrentUserId();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
    : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<String?> signUp(String email, String password) {
    return dataSource.signUp(email, password);
  }

  @override
  Future<void> signIn(String email, String password) {
    return dataSource.signIn(email, password);
  }

  @override
  Future<String?> getCurrentUserId() {
    return dataSource.getCurrentUserId();
  }
}
