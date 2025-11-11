import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';

class GetFavoritesCountUseCase {
  final FavoritesRepository repository;
  GetFavoritesCountUseCase(this.repository);

  Future<int> call(String recipeId) {
    return repository.getCountForRecipe(recipeId: recipeId);
  }
}
