import 'package:receta_ya/domain/model/recipe.dart';
import '../repository/recipe_repository.dart';

class GetRecipeByIdUseCase {
  final RecipeRepository repository;

  GetRecipeByIdUseCase(this.repository);

  Future<Recipe> call(String recipeId) async {
    return repository.getRecipeById(recipeId);
  }
}

