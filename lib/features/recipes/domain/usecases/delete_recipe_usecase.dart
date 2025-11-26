import '../repository/recipe_repository.dart';

class DeleteRecipeUseCase {
  final RecipeRepository repository;

  DeleteRecipeUseCase({required this.repository});

  Future<void> call(String recipeId) async {
    return await repository.deleteRecipe(recipeId);
  }
}
