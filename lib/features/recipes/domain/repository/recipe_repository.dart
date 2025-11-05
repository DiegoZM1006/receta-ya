import 'package:receta_ya/domain/model/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes({String? type, String? query});
}
