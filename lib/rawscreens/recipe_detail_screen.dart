import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import 'package:receta_ya/features/recipes/data/repository/recipe_repository_impl.dart';
import 'package:receta_ya/features/recipes/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/recipe_detail_cubit.dart';
import 'dart:math' as math;

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _selectedTab = 0; // 0 = Ingredientes, 1 = Calorias

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
              colors: [
                Color(0xFFE6F4FD),
                Color(0xFFF4EDFD),
              ],
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
                      colors: [
                        Color(0xFFE6F4FD),
                        Color(0xFFF4EDFD),
                      ],
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
                      colors: [
                        Color(0xFFE6F4FD),
                        Color(0xFFF4EDFD),
                      ],
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
                      colors: [
                        Color(0xFFE6F4FD),
                        Color(0xFFF4EDFD),
                      ],
                    ),
                  ),
                  child: const Center(child: Text('Receta no encontrada')),
                );
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
            currentIndex: 0, // Home está seleccionado ya que venimos de ahí
            onTap: (index) {
              // Volver a MainScreen
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
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
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: Column(
                children: [
                  _buildHeader(recipe),
                  const SizedBox(height: 16),
                  _buildRecipeImage(recipe),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildTabContent(recipe),
                  SizedBox(height: screenHeight * 0.1), // Espacio adicional para llenar
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
          Expanded(
            child: Center(
              child: Text(
                recipe.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF386BF6),
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    return Center(
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
          Expanded(
            child: _buildTabButton('Ingredientes', 0),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildTabButton('Calorias', 1),
          ),
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
    } else {
      return _buildCaloriesTab(recipe);
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
              _buildInfoItem(Icons.access_time, 'Tiempo', '${recipe.prepTimeMinutes ?? 0}min'),
              _buildInfoItem(Icons.star_border, 'Dificultad', recipe.difficulty ?? 'N/A'),
              _buildInfoItem(Icons.favorite_border, 'Favoritos', '0'),
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
          Text(
            'Ingredientes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...recipe.ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.rectangle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${ingredient.quantity.toStringAsFixed(0)}${ingredient.unit} ${ingredient.name}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
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
    final proteinPercent = totalMacroCalories > 0 ? proteinCalories / totalMacroCalories : 0.0;
    final carbPercent = totalMacroCalories > 0 ? carbCalories / totalMacroCalories : 0.0;
    final fatPercent = totalMacroCalories > 0 ? fatCalories / totalMacroCalories : 0.0;

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
                    _buildMacroItem('Proteinas (${proteins}g)', proteinCalories.toDouble(), const Color(0xFF1E88E5)),
                    const SizedBox(height: 12),
                    _buildMacroItem('Grasas (${fats}g)', fatCalories.toDouble(), Colors.amber),
                    const SizedBox(height: 12),
                    _buildMacroItem('Carbohidratos (${carbs}g)', carbCalories.toDouble(), const Color(0xFF42A5F5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesChart(double proteinPercent, double carbPercent, double fatPercent) {
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
            painter: _MacroChartPainter(proteinPercent, carbPercent, fatPercent),
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

