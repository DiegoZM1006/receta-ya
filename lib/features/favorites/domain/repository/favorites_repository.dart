abstract class FavoritesRepository {
  Future<void> addFavorite({required String userId, required String recipeId});
  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  });
  Future<bool> isFavorite({required String userId, required String recipeId});
  Future<List<String>> getFavoritesByUser({required String userId});
  Future<int> getCountForRecipe({required String recipeId});
}
