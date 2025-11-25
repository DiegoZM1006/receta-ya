import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/features/home/domain/model/gemini_recipe.dart';

class RecipeSaveService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> saveRecipe(GeminiRecipe geminiRecipe) async {
    try {
      print('Guardando receta: ${geminiRecipe.name}');

      final recipeData = {
        'name': geminiRecipe.name,
        'description': geminiRecipe.description,
        'instructions': geminiRecipe.instructions,
        'base_servings': geminiRecipe.servings,
        'prep_time': geminiRecipe.prepTimeMinutes,
        'difficulty': geminiRecipe.difficulty,
        'calories_per_serving': geminiRecipe.caloriesPerServing,
        'protein_per_serving': geminiRecipe.proteinPerServing,
        'carbs_per_serving': geminiRecipe.carbsPerServing,
        'fat_per_serving': geminiRecipe.fatPerServing,
        'image_url':
            'https://picsum.photos/seed/recipe${DateTime.now().millisecondsSinceEpoch}/800/600',
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Insertando receta en tabla recipes...');
      final recipeResponse = await _supabase
          .from('recipes')
          .insert(recipeData)
          .select('recipe_id')
          .single();

      print('Receta insertada correctamente');

      final recipeId = recipeResponse['recipe_id'].toString();
      print('Recipe ID: $recipeId');

      print('Guardando ${geminiRecipe.ingredients.length} ingredientes...');
      for (var ingredient in geminiRecipe.ingredients) {
        print('  - Procesando: ${ingredient.name}');

        // Buscar si el ingrediente ya existe
        final existingIngredient = await _supabase
            .from('ingredients')
            .select('ingredient_id')
            .eq('name', ingredient.name)
            .maybeSingle();

        String ingredientId;

        if (existingIngredient != null) {
          // El ingrediente ya existe
          ingredientId = existingIngredient['ingredient_id'].toString();
          print('    Ingrediente existente, ID: $ingredientId');
        } else {
          // Crear nuevo ingrediente
          final ingredientData = {
            'name': ingredient.name,
            'unit': ingredient.unit,
          };

          final newIngredient = await _supabase
              .from('ingredients')
              .insert(ingredientData)
              .select('ingredient_id')
              .single();

          ingredientId = newIngredient['ingredient_id'].toString();
          print('    Nuevo ingrediente creado, ID: $ingredientId');
        }

        // Insertar la relación receta-ingrediente
        await _supabase.from('recipe_ingredients').insert({
          'recipe_id': recipeId,
          'ingredient_id': ingredientId,
          'base_quantity': ingredient.quantity,
        });
      }

      print('✓ Todos los ingredientes guardados');
      return recipeId;
    } catch (e) {
      print('=== ERROR AL GUARDAR RECETA ===');
      print('Error: $e');
      rethrow;
    }
  }
}
