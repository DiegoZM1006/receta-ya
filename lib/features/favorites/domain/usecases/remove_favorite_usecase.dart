import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';

class RemoveFavoriteUseCase {
  final FavoritesRepository repository;
  RemoveFavoriteUseCase(this.repository);

  Future<void> execute({required String userId, required String recipeId}) {
    return repository.removeFavorite(userId: userId, recipeId: recipeId);
  }
}
