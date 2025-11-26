import 'package:flutter/material.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';
import 'package:receta_ya/core/widgets/custom_text_field.dart';
import 'package:receta_ya/core/widgets/primary_button.dart';
import 'package:receta_ya/core/widgets/gradient_background.dart';
import 'package:receta_ya/features/auth/domain/usecases/login_usecase.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginUseCase _loginUseCase = LoginUseCase();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login(String email, String pass) async {
    final trimmedEmail = email.trim();
    final trimmedPass = pass;

    if (trimmedEmail.isEmpty) {
      _showError('Por favor ingresa tu correo electrónico.');
      return;
    }

    // Enhanced email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      _showError('Por favor ingresa un correo electrónico válido.');
      return;
    }

    if (trimmedPass.isEmpty) {
      _showError('Por favor ingresa tu contraseña.');
      return;
    }

    if (trimmedPass.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _loginUseCase.execute(trimmedEmail, trimmedPass);
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('invalid') || text.contains('credentials')) {
        _showError(
          'Correo o contraseña incorrectos. Por favor verifica e inténtalo de nuevo.',
        );
      } else if (text.contains('user') && text.contains('not found')) {
        _showError('No existe una cuenta con ese correo. Regístrate primero.');
      } else if (text.contains('network') || text.contains('socket')) {
        _showError('Error de red. Revisa tu conexión e inténtalo de nuevo.');
      } else {
        _showError(
          'Ocurrió un error inesperado. Intenta nuevamente más tarde.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          'assets/images/logo_receta_ya.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Inicio de sesión', style: AppTextStyles.title),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  label: 'Correo Electrónico',
                  hintText: 'john@example.com',
                  suffixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onSubmitted: (_) =>
                      _login(emailController.text, passwordController.text),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: AppTextStyles.link,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Iniciar sesión',
                  isLoading: _isLoading,
                  onPressed: () =>
                      _login(emailController.text, passwordController.text),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: AppTextStyles.caption,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: Text('Regístrate', style: AppTextStyles.linkBold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
