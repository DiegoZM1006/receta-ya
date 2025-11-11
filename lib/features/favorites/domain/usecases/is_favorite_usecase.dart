import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';

class IsFavoriteUseCase {
  final FavoritesRepository repository;
  IsFavoriteUseCase(this.repository);

  Future<bool> execute({required String userId, required String recipeId}) {
    return repository.isFavorite(userId: userId, recipeId: recipeId);
  }
}
