import 'package:receta_ya/domain/model/recipe.dart';
import '../repository/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  Future<List<Recipe>> call({String? type, String? query}) async {
    return repository.getRecipes(type: type, query: query);
  }
}
