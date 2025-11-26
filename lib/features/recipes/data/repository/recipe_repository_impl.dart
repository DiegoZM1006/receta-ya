import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import '../../domain/repository/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;

  RecipeRepositoryImpl({required this.remote});

  @override
  Future<List<Recipe>> getRecipes({String? type, String? query}) async {
    return await remote.fetchRecipes(type: type, query: query);
  }

  @override
  Future<Recipe> getRecipeById(String recipeId) async {
    return await remote.fetchRecipeById(recipeId);
  }

  @override
  Future<String> createRecipe(Recipe recipe, List<String> mealTypeIds) async {
    return await remote.createRecipe(recipe, mealTypeIds);
  }

  @override
  Future<void> updateRecipe(String recipeId, Recipe recipe, List<String> mealTypeIds) async {
    return await remote.updateRecipe(recipeId, recipe, mealTypeIds);
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    return await remote.deleteRecipe(recipeId);
  }
}
