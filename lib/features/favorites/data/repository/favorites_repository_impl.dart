import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';
import 'package:receta_ya/features/favorites/data/source/favorites_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDataSource dataSource = FavoritesDataSourceImpl();

  @override
  Future<void> addFavorite({required String userId, required String recipeId}) {
    return dataSource.addFavorite(userId: userId, recipeId: recipeId);
  }

  @override
  Future<List<String>> getFavoritesByUser({required String userId}) {
    return dataSource.getFavoritesByUser(userId: userId);
  }

  @override
  Future<int> getCountForRecipe({required String recipeId}) {
    return dataSource.getCountForRecipe(recipeId: recipeId);
  }

  @override
  Future<bool> isFavorite({required String userId, required String recipeId}) {
    return dataSource.isFavorite(userId: userId, recipeId: recipeId);
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) {
    return dataSource.removeFavorite(userId: userId, recipeId: recipeId);
  }
}
