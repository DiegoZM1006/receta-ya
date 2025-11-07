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
}
