import 'package:receta_ya/domain/model/profile.dart';

abstract class UserRepository {
  Future<void> registerUser(Profile profile, String password);
}
