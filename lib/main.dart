import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/features/auth/ui/bloc/signup_bloc.dart';
import 'package:receta_ya/rawscreens/login_screen.dart';
import 'package:receta_ya/rawscreens/profile_screen.dart';
import 'package:receta_ya/features/auth/ui/screens/signup_screen.dart';
import 'package:receta_ya/rawscreens/main_screen.dart';
import 'package:receta_ya/features/onboarding/ui/screens/onboarding_screen.dart';
import 'package:receta_ya/rawscreens/favorites_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mqtmccaetlajrrhetlvi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xdG1jY2FldGxhanJyaGV0bHZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzE2NjIsImV4cCI6MjA3NTg0NzY2Mn0.tbo_vztN7rWAXwwSSMI4DGK7WyctdHIi8GM5-5PXOTE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas Ya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF386BF6),
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF386BF6)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/signup': (_) =>
            BlocProvider(create: (_) => RegisterBloc(), child: SignupScreen()),
        '/login': (_) => LoginScreen(),
        '/profile': (_) => ProfileScreen(),
        '/onboarding': (_) => OnboardingScreen(),
        '/favorites': (_) => FavoritesScreen(),
        '/main': (_) => MainScreen(),
      },
    );
  }
}
