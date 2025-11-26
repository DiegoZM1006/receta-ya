import 'package:receta_ya/domain/model/recipe.dart';
import '../repository/recipe_repository.dart';

class UpdateRecipeUseCase {
  final RecipeRepository repository;

  UpdateRecipeUseCase({required this.repository});

  Future<void> call(String recipeId, Recipe recipe, List<String> mealTypeIds) async {
    return await repository.updateRecipe(recipeId, recipe, mealTypeIds);
  }
}
