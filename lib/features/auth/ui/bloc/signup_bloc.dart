import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/auth/domain/usecases/register_user_usecase.dart';

abstract class RegisterEvent {}

class SubmitRegisterEvent extends RegisterEvent {
  final String email;
  final String name;
  final String password;
  SubmitRegisterEvent({
    required this.email,
    required this.name,
    required this.password,
  });
}

abstract class RegisterState {}

class RegisterIdle extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String message;
  RegisterError({required this.message});
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUseCase registerUserUseCase = RegisterUserUseCase();

  RegisterBloc() : super(RegisterIdle()) {
    on<SubmitRegisterEvent>(_onSubmitRegister);
  }

  Future<void> _onSubmitRegister(
    SubmitRegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    // Validate inputs
    final trimmedName = event.name.trim();
    final trimmedEmail = event.email.trim();
    final trimmedPassword = event.password;

    if (trimmedName.isEmpty) {
      emit(RegisterError(message: 'Por favor ingresa tu nombre'));
      return;
    }

    if (trimmedName.length < 2) {
      emit(RegisterError(message: 'El nombre debe tener al menos 2 caracteres'));
      return;
    }

    if (trimmedEmail.isEmpty) {
      emit(RegisterError(message: 'Por favor ingresa tu correo electrónico'));
      return;
    }

    // Email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      emit(RegisterError(message: 'Por favor ingresa un correo electrónico válido'));
      return;
    }

    if (trimmedPassword.isEmpty) {
      emit(RegisterError(message: 'Por favor ingresa tu contraseña'));
      return;
    }

    if (trimmedPassword.length < 6) {
      emit(RegisterError(message: 'La contraseña debe tener al menos 6 caracteres'));
      return;
    }

    // Check password strength
    if (!trimmedPassword.contains(RegExp(r'[0-9]'))) {
      emit(RegisterError(message: 'La contraseña debe contener al menos un número'));
      return;
    }

    emit(RegisterLoading());
    try {
      await registerUserUseCase.execute(
        Profile(
          id: "",
          name: trimmedName,
          email: trimmedEmail,
          createdAt: DateTime.now(),
        ),
        trimmedPassword,
      );
      emit(RegisterSuccess());
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('already') || errorMessage.contains('exists')) {
        emit(RegisterError(message: 'Este correo ya está registrado'));
      } else if (errorMessage.contains('network') || errorMessage.contains('socket')) {
        emit(RegisterError(message: 'Error de red. Revisa tu conexión'));
      } else {
        emit(RegisterError(message: 'No se pudo registrar el usuario'));
      }
    }
  }
}
