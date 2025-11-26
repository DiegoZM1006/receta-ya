import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';
import 'package:receta_ya/core/widgets/custom_text_field.dart';
import 'package:receta_ya/core/widgets/primary_button.dart';
import 'package:receta_ya/core/widgets/gradient_background.dart';
import 'package:receta_ya/features/auth/domain/usecases/request_password_reset_usecase.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final RequestPasswordResetUseCase _requestPasswordResetUseCase =
      RequestPasswordResetUseCase();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Por favor ingresa tu correo electrónico');
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      _showError('Por favor ingresa un correo electrónico válido');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _requestPasswordResetUseCase.execute(email);
      setState(() {
        _emailSent = true;
      });
      _showSuccess(
        'Se ha enviado un correo a $email con instrucciones para restablecer tu contraseña',
      );
    } catch (e) {
      _showError('Error al enviar el correo. Por favor intenta de nuevo.');
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
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(
          Icons.lock_reset,
          size: 80,
          color: Colors.blue[700],
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          '¿Olvidaste tu contraseña?',
          style: AppTextStyles.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Email field
        CustomTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hintText: 'john@example.com',
          suffixIcon: Icons.email_outlined,
          onSubmitted: (_) => _requestReset(),
        ),
        const SizedBox(height: 30),

        // Submit button
        PrimaryButton(
          text: 'Enviar enlace',
          isLoading: _isLoading,
          onPressed: _requestReset,
        ),
        const SizedBox(height: 20),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Volver al inicio de sesión',
            style: AppTextStyles.link,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          '¡Correo enviado!',
          style: AppTextStyles.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Message
        Text(
          'Revisa tu bandeja de entrada y haz clic en el enlace para restablecer tu contraseña.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Nota: Si no recibes el correo en unos minutos, revisa tu carpeta de spam.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue[900],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),

        // Resend button
        OutlinedButton(
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _emailSent = false;
                  });
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Enviar de nuevo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Volver al inicio de sesión',
            style: AppTextStyles.link,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
