import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';

class AddFavoriteUseCase {
  final FavoritesRepository repository;
  AddFavoriteUseCase(this.repository);

  Future<void> execute({required String userId, required String recipeId}) {
    return repository.addFavorite(userId: userId, recipeId: recipeId);
  }
}
