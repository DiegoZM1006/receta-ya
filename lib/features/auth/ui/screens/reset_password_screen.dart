import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';
import 'package:receta_ya/core/widgets/custom_text_field.dart';
import 'package:receta_ya/core/widgets/primary_button.dart';
import 'package:receta_ya/core/widgets/gradient_background.dart';
import 'package:receta_ya/features/auth/domain/usecases/update_password_usecase.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UpdatePasswordUseCase _updatePasswordUseCase = UpdatePasswordUseCase();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showError('Por favor ingresa tu nueva contraseña');
      return;
    }

    if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _showError('La contraseña debe contener al menos un número');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showError('Por favor confirma tu contraseña');
      return;
    }

    if (password != confirmPassword) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _updatePasswordUseCase.execute(password);
      _showSuccess('Contraseña actualizada correctamente');
      
      // Navigate to login after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Error al actualizar la contraseña. Por favor intenta de nuevo.');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.lock_open,
                  size: 80,
                  color: Colors.blue[700],
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Nueva contraseña',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Ingresa tu nueva contraseña',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Nueva Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  hintText: 'Repite tu contraseña',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  onSubmitted: (_) => _resetPassword(),
                ),

                const SizedBox(height: 12),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'La contraseña debe tener:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRequirement('Al menos 6 caracteres'),
                      _buildRequirement('Al menos un número'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Submit button
                PrimaryButton(
                  text: 'Actualizar contraseña',
                  isLoading: _isLoading,
                  onPressed: _resetPassword,
                ),
                
                const SizedBox(height: 20),

                // Back to login button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Volver al inicio de sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF386BF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
