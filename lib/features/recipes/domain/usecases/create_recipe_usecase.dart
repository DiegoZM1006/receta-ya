import 'package:receta_ya/domain/model/recipe.dart';
import '../repository/recipe_repository.dart';

class CreateRecipeUseCase {
  final RecipeRepository repository;

  CreateRecipeUseCase({required this.repository});

  Future<String> call(Recipe recipe, List<String> mealTypeIds) async {
    return await repository.createRecipe(recipe, mealTypeIds);
  }
}
