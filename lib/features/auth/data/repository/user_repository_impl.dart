import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/auth/data/source/auth_data_source.dart';
import 'package:receta_ya/features/auth/domain/repository/auth_repository.dart';
import 'package:receta_ya/features/profile/data/source/profile_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthDataSource authDataSource = AuthDataSourceImpl();
  final ProfileDataSource profileDataSource = ProfileDataSourceImpl();

  @override
  Future<void> registerUser(Profile profile, String password) async {
    try {
      // Paso 1: Crear usuario en Supabase Auth
      final userId = await authDataSource.signUp(profile.email, password);
      
      if (userId != null) {
        // Paso 2: Usar el ID generado por Supabase Auth (UUID)
        profile.id = userId;
        print('Usuario creado en Auth con ID: $userId');
        
        // Paso 3: Crear entrada en la tabla users con el mismo UUID
        await profileDataSource.createProfile(profile);
        print('Registro completado exitosamente');
      } else {
        throw Exception('No se pudo obtener el ID del usuario después del registro');
      }
    } catch (e) {
      print('Error en el proceso de registro: $e');
      throw Exception('Error al registrar usuario: $e');
    }
  }
}
