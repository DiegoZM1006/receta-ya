// data/datasources/auth_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthDataSource {
  Future<String?> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<String?> getCurrentUserId();
}

class AuthDataSourceImpl extends AuthDataSource {
  @override
  Future<String?> signUp(String email, String password) async {
    AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response.user?.id;
  }

  @override
  Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<String?> getCurrentUserId() async {
    return Supabase.instance.client.auth.currentUser?.id;
  }
}
