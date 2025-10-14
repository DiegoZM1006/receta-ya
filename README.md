# Receta Ya

Aplicación móvil Flutter para gestionar recetas y preferencias de usuario.

Este README contiene instrucciones básicas para ejecutar la app en desarrollo y para navegar por los flujos principales (registro, onboarding y perfil).

## Requisitos
- Flutter SDK (compatible con la versión usada en el proyecto)
- Dart (incluido con Flutter)
- Un emulador o dispositivo conectado
- Cuenta y proyecto en Supabase (el proyecto ya contiene la inicialización en `lib/main.dart`)

## Instalación y ejecución (PowerShell)

1. Obtener dependencias:

```powershell
flutter pub get
```

2. Ejecutar la app en un emulador o dispositivo conectado:

```powershell
flutter run
```

## Rutas y flujos principales

La app define rutas en `lib/main.dart`. Las rutas más relevantes son:

- `/login` → Pantalla de inicio de sesión (rawscreens/login_screen.dart)
- `/signup` → Pantalla de registro (lib/features/auth/ui/screens/signup_screen.dart)
- `/onboarding` → Flow de onboarding (lib/features/onboarding/ui/screens/onboarding_screen.dart)
- `/profile` → Pantalla de perfil (lib/rawscreens/profile_screen.dart)
- `/main` → Pantalla principal de la app (lib/rawscreens/main_screen.dart)

Flujos típicos:

- Registro (nuevo usuario):
	1. Ir a `/signup` y completar nombre, email y contraseña.
	2. Tras registro exitoso, la app navegará automáticamente a `/onboarding`.
	3. Completar las 4 pantallas del onboarding (habilidad de cocina, objetivos, porciones típicas y tiempo de cocinado).
	4. Al finalizar, las preferencias se guardan en la tabla `users` de Supabase y la app navegará a `/profile`.

- Inicio de sesión:
	1. Ir a `/login` y autenticarse.
	2. Tras iniciar sesión la app navega a `/main`.

