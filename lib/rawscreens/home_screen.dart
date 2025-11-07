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
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/features/profile/data/source/profile_data_source.dart';
import 'package:receta_ya/rawscreens/recipe_detail_screen.dart';
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
      final profile = await ProfileDataSourceImpl().getProfile(user.id);
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
                          label: const Text('Todas'),
                          selected: _selectedFilter == 'Todas',
                          onSelected: (_) => _onFilterSelected('Todas'),
                          selectedColor: const Color(0xFF386BF6),
                        ),
                      );

                      for (var t in mState.mealTypes) {
                        chips.add(
                          ChoiceChip(
                            label: Text(t.name),
                            selected: _selectedFilter == t.name,
                            onSelected: (_) => _onFilterSelected(t.name),
                            selectedColor: const Color(0xFF386BF6),
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

                      return ListView.builder(
                        itemCount: state.recipes.length,
                        itemBuilder: (context, index) {
                          final Recipe r = state.recipes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: SizedBox(
                                width: 56,
                                height: 56,
                                child: r.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          r.imageUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                          ),
                                        ),
                                      )
                                    : Container(width: 56, height: 56, color: Colors.grey[200]),
                              ),
                              title: Text(r.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text('${r.caloriesPerPortion != null ? r.caloriesPerPortion!.toInt() : 0} kcal${(r.types.isNotEmpty ? ' • ${r.types.join(', ')}' : (r.difficulty != null ? ' • ${r.difficulty}' : ''))}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(recipeId: r.id),
                                    ),
                                  );
                                },
                                child: const Text('Ver receta'),
                              ),
                            ),
                          );
                        },
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

