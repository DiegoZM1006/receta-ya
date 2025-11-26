import 'package:receta_ya/domain/model/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes({String? type, String? query});
  Future<Recipe> getRecipeById(String recipeId);
  Future<String> createRecipe(Recipe recipe, List<String> mealTypeIds);
  Future<void> updateRecipe(String recipeId, Recipe recipe, List<String> mealTypeIds);
  Future<void> deleteRecipe(String recipeId);
}
