import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import 'package:receta_ya/features/recipes/data/repository/recipe_repository_impl.dart';
import 'package:receta_ya/features/recipes/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/recipe_detail_cubit.dart';
import 'dart:math' as math;
import 'package:receta_ya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:receta_ya/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:receta_ya/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:receta_ya/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:receta_ya/features/favorites/domain/usecases/is_favorite_usecase.dart';
import 'package:receta_ya/features/favorites/domain/usecases/get_favorites_count_usecase.dart';
import 'package:receta_ya/features/home/ui/main_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _selectedTab = 0; // 0 = Ingredientes, 1 = Calorias, 2 = Instrucciones
  bool _isFavorite = false;
  bool _favoriteLoaded = false;
  final _favoritesRepo = FavoritesRepositoryImpl();
  late final AddFavoriteUseCase _addFavorite;
  late final RemoveFavoriteUseCase _removeFavorite;
  late final IsFavoriteUseCase _isFavoriteUseCase;
  late final GetFavoritesCountUseCase _getFavoritesCount;
  int _favoritesCount = 0;
  int _desiredServings = 1;
  
  // Cooking mode checklist state
  final Map<String, bool> _ingredientChecklist = {};

  @override
  void initState() {
    super.initState();
    _addFavorite = AddFavoriteUseCase(_favoritesRepo);
    _removeFavorite = RemoveFavoriteUseCase(_favoritesRepo);
    _isFavoriteUseCase = IsFavoriteUseCase(_favoritesRepo);
    _getFavoritesCount = GetFavoritesCountUseCase(_favoritesRepo);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeDetailCubit(
        getRecipeById: GetRecipeByIdUseCase(
          RecipeRepositoryImpl(remote: RecipeRemoteDataSource()),
        ),
      )..loadRecipeById(widget.recipeId),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
            ),
          ),
          child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
            builder: (context, state) {
              if (state.status == RecipeDetailStatus.loading) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == RecipeDetailStatus.failure) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error al cargar la receta',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.recipe == null) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
                    ),
                  ),
                  child: const Center(child: Text('Receta no encontrada')),
                );
              }

              // Ensure favorite status is loaded once after recipe is available
              if (!_favoriteLoaded && state.recipe != null) {
                _favoriteLoaded = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadFavoriteStatus(state.recipe!.id);
                  if (state.recipe!.baseServings != null &&
                      state.recipe!.baseServings! > 0) {
                    setState(
                      () => _desiredServings = state.recipe!.baseServings!,
                    );
                  }
                  _loadFavoritesCount(state.recipe!.id);
                });
              }

              return _buildRecipeContent(state.recipe!);
            },
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
                (route) => false,
              );
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF386BF6),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
        floatingActionButton: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            if (state.recipe == null) return const SizedBox.shrink();
            return _buildCookButton(state.recipe!);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildRecipeContent(Recipe recipe) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  _buildHeader(recipe),
                  const SizedBox(height: 16),
                  _buildRecipeImage(recipe),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildTabContent(recipe),
                  SizedBox(
                    height: screenHeight * 0.1,
                  ), // Espacio adicional para llenar
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () async {
                final getCurrentUser = GetCurrentUserUseCase();
                final userId = await getCurrentUser.execute();
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Debes iniciar sesión para guardar favoritos',
                      ),
                    ),
                  );
                  return;
                }
                final recipeId = recipe.id;
                try {
                  if (_isFavorite) {
                    await _removeFavorite.execute(
                      userId: userId,
                      recipeId: recipeId,
                    );
                    setState(() {
                      _isFavorite = false;
                      if (_favoritesCount > 0) _favoritesCount--;
                    });
                  } else {
                    await _addFavorite.execute(
                      userId: userId,
                      recipeId: recipeId,
                    );
                    setState(() {
                      _isFavorite = true;
                      _favoritesCount++;
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al actualizar favoritos'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFavoriteStatus(String recipeId) async {
    final getCurrentUser = GetCurrentUserUseCase();
    final userId = await getCurrentUser.execute();
    if (userId == null) return;
    try {
      final fav = await _isFavoriteUseCase.execute(
        userId: userId,
        recipeId: recipeId,
      );
      if (!mounted) return;
      setState(() => _isFavorite = fav);
    } catch (e) {}
  }

  Future<void> _loadFavoritesCount(String recipeId) async {
    try {
      final count = await _getFavoritesCount.call(recipeId);
      if (!mounted) return;
      setState(() => _favoritesCount = count);
    } catch (e) {
      // ignore
    }
  }

  Widget _buildRecipeImage(Recipe recipe) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            recipe.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF386BF6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Ingredientes', 0)),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(child: _buildTabButton('Calorías', 1)),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(child: _buildTabButton('Preparación', 2)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF386BF6), width: 3),
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Recipe recipe) {
    if (_selectedTab == 0) {
      return _buildIngredientsTab(recipe);
    } else if (_selectedTab == 1) {
      return _buildCaloriesTab(recipe);
    } else {
      return _buildInstructionsTab(recipe);
    }
  }

  Widget _buildIngredientsTab(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.access_time,
                'Tiempo',
                '${recipe.prepTimeMinutes ?? 0}min',
              ),
              _buildInfoItem(
                Icons.star_border,
                'Dificultad',
                recipe.difficulty ?? 'N/A',
              ),
              _buildInfoItem(
                Icons.favorite_border,
                'Favoritos',
                '$_favoritesCount',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recipe.description != null && recipe.description!.isNotEmpty)
            Text(
              recipe.description!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (recipe.description != null && recipe.description!.isNotEmpty)
            const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredientes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Porciones base: ${recipe.baseServings ?? 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  _buildServingsSelector(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recipe.ingredients.map(
            (ingredient) => _buildIngredientItem(ingredient, recipe),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(ingredient, Recipe recipe) {
    // Calculate adjusted quantity based on desired servings
    final baseServings =
        (recipe.baseServings != null && recipe.baseServings! > 0)
        ? recipe.baseServings!
        : 1;
    final factor = _desiredServings / baseServings;
    final adjusted = (ingredient.quantity * factor);
    // Prepare display strings
    final baseQtyStr =
        '${_formatQuantity(ingredient.quantity)} ${ingredient.unit}';
    final adjustedQtyStr = '${_formatQuantity(adjusted)} ${ingredient.unit}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.rectangle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Base quantity (muted)
                    Text(
                      baseQtyStr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Arrow separator
                    Text(
                      '→',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    // Adjusted quantity with subtle animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final fade = animation.drive(
                          CurveTween(curve: Curves.easeInOut),
                        );
                        final offset = animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0, -0.05),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOut)),
                        );
                        return FadeTransition(
                          opacity: fade,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        adjustedQtyStr,
                        key: ValueKey<String>(
                          'qty_${ingredient.id}_$_desiredServings',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF386BF6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Optional small badge showing current servings (subtle)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x$_desiredServings',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (_desiredServings > 1) setState(() => _desiredServings--);
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 120),
                child: const Icon(Icons.remove, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Animated number for servings (subtle fade + slide)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final fade = animation.drive(CurveTween(curve: Curves.easeInOut));
              final offset = animation.drive(
                Tween<Offset>(
                  begin: const Offset(0, -0.05),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              );
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: Text(
              '$_desiredServings',
              key: ValueKey<int>(_desiredServings),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _desiredServings++),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 120),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double q) {
    if (q <= 0) return q.toStringAsFixed(0);
    // If close to integer, show no decimals
    if ((q - q.round()).abs() < 0.01) return q.round().toString();
    // For small quantities show 2 decimals, otherwise 1
    if (q < 1) return q.toStringAsFixed(2);
    if (q < 10) return q.toStringAsFixed(1);
    return q.toStringAsFixed(0);
  }

  Widget _buildCaloriesTab(Recipe recipe) {
    final calories = recipe.caloriesPerPortion ?? 0;
    final proteins = recipe.proteinsPerPortion ?? 0;
    final carbs = recipe.carbsPerPortion ?? 0;
    final fats = recipe.fatsPerPortion ?? 0;

    // Calcular calorías de cada macronutriente
    final proteinCalories = proteins * 4;
    final carbCalories = carbs * 4;
    final fatCalories = fats * 9;

    final totalMacroCalories = proteinCalories + carbCalories + fatCalories;

    // Porcentajes para el gráfico
    final proteinPercent = totalMacroCalories > 0
        ? proteinCalories / totalMacroCalories
        : 0.0;
    final carbPercent = totalMacroCalories > 0
        ? carbCalories / totalMacroCalories
        : 0.0;
    final fatPercent = totalMacroCalories > 0
        ? fatCalories / totalMacroCalories
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calorias totales',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${calories.toInt()} kcal',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF386BF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCaloriesChart(proteinPercent, carbPercent, fatPercent),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMacroItem(
                      'Proteinas (${proteins}g)',
                      proteinCalories.toDouble(),
                      const Color(0xFF1E88E5),
                    ),
                    const SizedBox(height: 12),
                    _buildMacroItem(
                      'Grasas (${fats}g)',
                      fatCalories.toDouble(),
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroItem(
                      'Carbohidratos (${carbs}g)',
                      carbCalories.toDouble(),
                      const Color(0xFF42A5F5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart(
    double proteinPercent,
    double carbPercent,
    double fatPercent,
  ) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
            ),
          ),
          CustomPaint(
            size: const Size(120, 120),
            painter: _MacroChartPainter(
              proteinPercent,
              carbPercent,
              fatPercent,
            ),
          ),
          const Icon(
            Icons.local_fire_department,
            size: 40,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double calories, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: ${calories.toInt()} kcal',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsTab(Recipe recipe) {
    final instructions = recipe.instructions;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: Color(0xFF386BF6),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Preparación',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF386BF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (instructions != null && instructions.isNotEmpty)
            Text(
              instructions,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.8,
                color: Colors.grey[800],
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay instrucciones disponibles',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Cooking mode button
  Widget _buildCookButton(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 16), 
      child: FloatingActionButton(
        onPressed: () => _showIngredientsChecklist(recipe),
        backgroundColor: const Color(0xFF386BF6),
        elevation: 3,
        mini: true, 
        child: const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showIngredientsChecklist(Recipe recipe) {
    _resetChecklist(recipe.ingredients);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChecklistModal(recipe),
    );
  }

  Widget _buildChecklistModal(Recipe recipe) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildModalHandle(),
              _buildModalHeaderWithState(recipe, setModalState),
              Expanded(child: _buildModalBody(recipe)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildModalHeader(Recipe recipe) {
    final allChecked = recipe.ingredients.isNotEmpty && 
        recipe.ingredients.every((ing) => _ingredientChecklist[ing.id] ?? false);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lista de Ingredientes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Para $_desiredServings ${_desiredServings == 1 ? "porción" : "porciones"}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _toggleAllIngredients(!allChecked, recipe.ingredients);
                  });
                },
                icon: Icon(
                  allChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: const Color(0xFF386BF6),
                ),
                label: Text(
                  allChecked ? 'Desmarcar' : 'Marcar todos',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF386BF6),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeaderWithState(Recipe recipe, StateSetter setModalState) {
    final allChecked = recipe.ingredients.isNotEmpty && 
        recipe.ingredients.every((ing) => _ingredientChecklist[ing.id] ?? false);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lista de Ingredientes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Para $_desiredServings ${_desiredServings == 1 ? "porción" : "porciones"}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setModalState(() {
                    _toggleAllIngredients(!allChecked, recipe.ingredients);
                  });
                },
                icon: Icon(
                  allChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: const Color(0xFF386BF6),
                ),
                label: Text(
                  allChecked ? 'Desmarcar' : 'Marcar todos',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF386BF6),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalBody(Recipe recipe) {
    return Center(
      child: Text(
        'TODO: Implementar lista en siguiente commit',
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  // Checklist management methods
  void _resetChecklist(List<dynamic> ingredients) {
    _ingredientChecklist.clear();
    for (var ingredient in ingredients) {
      _ingredientChecklist[ingredient.id] = false;
    }
  }

  void _toggleIngredient(String ingredientId) {
    setState(() {
      _ingredientChecklist[ingredientId] = !(_ingredientChecklist[ingredientId] ?? false);
    });
  }

  void _toggleAllIngredients(bool value, List<dynamic> ingredients) {
    setState(() {
      for (var ingredient in ingredients) {
        _ingredientChecklist[ingredient.id] = value;
      }
    });
  }
}

class _MacroChartPainter extends CustomPainter {
  final double proteinPercent;
  final double carbPercent;
  final double fatPercent;

  _MacroChartPainter(this.proteinPercent, this.carbPercent, this.fatPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    double startAngle = -math.pi / 2; // Comenzar desde arriba

    // Proteínas (azul oscuro)
    if (proteinPercent > 0) {
      final proteinSweep = 2 * math.pi * proteinPercent;
      final proteinPaint = Paint()
        ..color = const Color(0xFF1E88E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        proteinSweep,
        false,
        proteinPaint,
      );
      startAngle += proteinSweep;
    }

    // Grasas (amarillo)
    if (fatPercent > 0) {
      final fatSweep = 2 * math.pi * fatPercent;
      final fatPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fatSweep,
        false,
        fatPaint,
      );
      startAngle += fatSweep;
    }

    // Carbohidratos (azul claro)
    if (carbPercent > 0) {
      final carbSweep = 2 * math.pi * carbPercent;
      final carbPaint = Paint()
        ..color = const Color(0xFF42A5F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        carbSweep,
        false,
        carbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
