import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import 'package:receta_ya/features/recipes/data/repository/recipe_repository_impl.dart';
import 'package:receta_ya/features/recipes/domain/usecases/get_recipes_usecase.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/recipes_cubit.dart';
import 'package:receta_ya/features/meal_types/data/source/meal_type_remote_datasource.dart';
import 'package:receta_ya/features/meal_types/data/repository/meal_type_repository_impl.dart';
import 'package:receta_ya/features/meal_types/domain/usecases/get_meal_types_usecase.dart';
import 'package:receta_ya/features/meal_types/presentation/cubit/meal_types_cubit.dart';
import 'package:receta_ya/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todas';
  String _userName = 'Usuario';
  late final RecipesCubit _recipesCubit;
  late final MealTypesCubit _mealTypesCubit;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _recipesCubit = RecipesCubit(
      getRecipes: GetRecipesUseCase(
        RecipeRepositoryImpl(remote: RecipeRemoteDataSource()),
      ),
    );
    _mealTypesCubit = MealTypesCubit(
      getMealTypes: GetMealTypesUseCase(
        MealTypeRepositoryImpl(remote: MealTypeRemoteDataSource()),
      ),
    );
    _recipesCubit.loadRecipes();
    _mealTypesCubit.loadMealTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recipesCubit.close();
    _mealTypesCubit.close();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final getProfileUseCase = GetProfileUseCase();
      final profile = await getProfileUseCase.execute(user.id);
      if (profile != null && profile.name.isNotEmpty) {
        setState(() {
          _userName = profile.name;
        });
      } else {
        setState(() {
          _userName = user.email ?? 'Usuario';
        });
      }
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _recipesCubit),
        BlocProvider.value(value: _mealTypesCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Buenos días', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('¿Qué receta quieres cocinar hoy?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF386BF6))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Escribe una receta...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (value) => _onSearch(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: BlocBuilder<MealTypesCubit, MealTypesState>(
                    builder: (context, mState) {
                      if (mState.status == MealTypesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (mState.status == MealTypesStatus.failure) {
                        // show a simple fallback: 'Todas' only
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ChoiceChip(
                              label: const Text('Todas'),
                              selected: _selectedFilter == 'Todas',
                              onSelected: (_) => _onFilterSelected('Todas'),
                              selectedColor: const Color(0xFF386BF6),
                            ),
                          ],
                        );
                      }

                      final chips = <Widget>[];
                      // always include 'Todas' first
                      chips.add(
                        ChoiceChip(
                          label: Text('Todas',
                            style: TextStyle(
                              color: _selectedFilter == "Todas" ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: _selectedFilter == 'Todas',
                          showCheckmark: false,
                          onSelected: (_) => _onFilterSelected('Todas'),
                          selectedColor: const Color(0xFF386BF6),
                        ),
                      );

                      for (var t in mState.mealTypes) {
                        chips.add(
                          ChoiceChip(
                            label: Text(
                              t.name,
                              style: TextStyle(
                                color: _selectedFilter == t.name ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: _selectedFilter == t.name,
                            onSelected: (_) => _onFilterSelected(t.name),
                            selectedColor: const Color(0xFF386BF6),
                            backgroundColor: Colors.white,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF386BF6)),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: chips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => chips[index],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<RecipesCubit, RecipesState>(
                    builder: (context, state) {
                      if (state.status == RecipesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == RecipesStatus.failure) {
                        return Center(child: Text('Error: ${state.errorMessage}'));
                      }

                      if (state.recipes.isEmpty) {
                        return const Center(child: Text('No se encontraron recetas'));
                      }

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final r in state.recipes)
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 44) / 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF7F8FD), Color(0xFFE9ECF8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: r.imageUrl != null
                                                    ? Image.network(
                                                  r.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(Icons.image_not_supported,
                                                        color: Colors.grey),
                                                  ),
                                                )
                                                    : Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 8,
                                              bottom: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.local_fire_department,
                                                        color: Colors.orange, size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${r.caloriesPerPortion?.toInt() ?? 0} kcal',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(

                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                                  backgroundColor: const Color(0xFF386BF6),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Ver receta',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.add, color: Colors.black87),
                                                onPressed: () {},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    _recipesCubit.loadRecipes(type: _selectedFilter == 'Todas' ? null : _selectedFilter, query: query.isEmpty ? null : query);
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // reload
    _recipesCubit.loadRecipes(type: filter == 'Todas' ? null : filter, query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim());
  }
}

