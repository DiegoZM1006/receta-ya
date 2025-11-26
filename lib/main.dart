import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/features/auth/ui/bloc/signup_bloc.dart';
import 'package:receta_ya/features/auth/ui/screens/login_screen.dart';
import 'package:receta_ya/features/auth/ui/screens/forgot_password_screen.dart';
import 'package:receta_ya/features/auth/ui/screens/reset_password_screen.dart';
import 'package:receta_ya/features/profile/ui/screens/profile_screen.dart';
import 'package:receta_ya/features/auth/ui/screens/signup_screen.dart';
import 'package:receta_ya/features/home/ui/main_screen.dart';
import 'package:receta_ya/features/onboarding/ui/screens/onboarding_screen.dart';
import 'package:receta_ya/features/favorites/ui/favorites_screen.dart';
import 'package:receta_ya/features/recipes/ui/admin_recipes_screen.dart';
import 'package:receta_ya/features/recipes/ui/create_recipe_screen.dart';
import 'package:receta_ya/features/recipes/ui/edit_recipe_screen.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/recipes_cubit.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/admin_recipes_cubit.dart';
import 'package:receta_ya/features/recipes/domain/usecases/get_recipes_usecase.dart';
import 'package:receta_ya/features/recipes/domain/usecases/create_recipe_usecase.dart';
import 'package:receta_ya/features/recipes/domain/usecases/update_recipe_usecase.dart';
import 'package:receta_ya/features/recipes/domain/usecases/delete_recipe_usecase.dart';
import 'package:receta_ya/features/recipes/data/repository/recipe_repository_impl.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import 'package:receta_ya/features/meal_types/presentation/cubit/meal_types_cubit.dart';
import 'package:receta_ya/features/meal_types/domain/usecases/get_meal_types_usecase.dart';
import 'package:receta_ya/features/meal_types/data/repository/meal_type_repository_impl.dart';
import 'package:receta_ya/features/meal_types/data/source/meal_type_remote_datasource.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://mqtmccaetlajrrhetlvi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xdG1jY2FldGxhanJyaGV0bHZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzE2NjIsImV4cCI6MjA3NTg0NzY2Mn0.tbo_vztN7rWAXwwSSMI4DGK7WyctdHIi8GM5-5PXOTE',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Manejar deep link cuando la app ya está abierta
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Manejar deep link cuando la app se abre desde cerrada
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('Error al obtener deep link inicial: $e');
    }

    // Escuchar cambios de autenticación
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushReplacementNamed('/reset-password');
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print('Deep link recibido: $uri');
    
    if (uri.scheme == 'recetaya' && uri.host == 'reset-password') {
      // Navegar a la pantalla de reset password
      navigatorKey.currentState?.pushReplacementNamed('/reset-password');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Recetas Ya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF386BF6),
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF386BF6)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Manejar rutas con parámetros
        if (settings.name == '/admin/edit-recipe') {
          final recipe = settings.arguments as Recipe;
          return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => AdminRecipesCubit(
                    createRecipe: CreateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    updateRecipe: UpdateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    deleteRecipe: DeleteRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
                BlocProvider(
                  create: (_) => MealTypesCubit(
                    getMealTypes: GetMealTypesUseCase(
                      MealTypeRepositoryImpl(
                        remote: MealTypeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
              ],
              child: EditRecipeScreen(recipe: recipe),
            ),
          );
        }
        return null;
      },
      routes: {
        '/signup': (_) =>
            BlocProvider(create: (_) => RegisterBloc(), child: SignupScreen()),
        '/login': (_) => LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/profile': (_) => ProfileScreen(),
        '/onboarding': (_) => OnboardingScreen(),
        '/favorites': (_) => FavoritesScreen(),
        '/main': (_) => MainScreen(),
        '/admin/recipes': (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => RecipesCubit(
                    getRecipes: GetRecipesUseCase(
                      RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
                BlocProvider(
                  create: (_) => AdminRecipesCubit(
                    createRecipe: CreateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    updateRecipe: UpdateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    deleteRecipe: DeleteRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
              ],
              child: const AdminRecipesScreen(),
            ),
        '/admin/create-recipe': (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => AdminRecipesCubit(
                    createRecipe: CreateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    updateRecipe: UpdateRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                    deleteRecipe: DeleteRecipeUseCase(
                      repository: RecipeRepositoryImpl(
                        remote: RecipeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
                BlocProvider(
                  create: (_) => MealTypesCubit(
                    getMealTypes: GetMealTypesUseCase(
                      MealTypeRepositoryImpl(
                        remote: MealTypeRemoteDataSource(),
                      ),
                    ),
                  ),
                ),
              ],
              child: const CreateRecipeScreen(),
            ),
      },
    );
  }
}
