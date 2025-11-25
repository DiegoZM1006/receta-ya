import 'package:receta_ya/features/home/data/service/gemini_service.dart';
import 'package:receta_ya/features/home/data/service/recipe_save_service.dart';

class GenerateRecipeUseCase {
  final GeminiService _geminiService;
  final RecipeSaveService _recipeSaveService;

  GenerateRecipeUseCase({
    GeminiService? geminiService,
    RecipeSaveService? recipeSaveService,
  }) : _geminiService = geminiService ?? GeminiService(),
       _recipeSaveService = recipeSaveService ?? RecipeSaveService();

  Future<Map<String, dynamic>> execute(String ingredients) async {
    try {
      print('=== INICIANDO GENERACIÓN DE RECETA ===');
      print('Ingredientes: $ingredients');

      final recipe = await _geminiService.generateRecipe(ingredients);
      print('✓ Receta generada exitosamente: ${recipe.name}');

      print('=== GUARDANDO EN BASE DE DATOS ===');
      final recipeId = await _recipeSaveService.saveRecipe(recipe);
      print('✓ Receta guardada con ID: $recipeId');

      return {'recipe': recipe, 'recipeId': recipeId};
    } catch (e) {
      print('=== ERROR EN USE CASE ===');
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
