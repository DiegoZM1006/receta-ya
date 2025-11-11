import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FavoritesDataSource {
  Future<void> addFavorite({required String userId, required String recipeId});
  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  });
  Future<bool> isFavorite({required String userId, required String recipeId});
  Future<List<String>> getFavoritesByUser({required String userId});
  Future<int> getCountForRecipe({required String recipeId});
}

class FavoritesDataSourceImpl extends FavoritesDataSource {
  final _client = Supabase.instance.client;

  @override
  Future<void> addFavorite({
    required String userId,
    required String recipeId,
  }) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'recipe_id': recipeId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    await _client.from('favorites').delete().match({
      'user_id': userId,
      'recipe_id': recipeId,
    });
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String recipeId,
  }) async {
    final resp = await _client
        .from('favorites')
        .select('*')
        .match({'user_id': userId, 'recipe_id': recipeId})
        .limit(1)
        .maybeSingle();
    return resp != null;
  }

  @override
  Future<List<String>> getFavoritesByUser({required String userId}) async {
    final resp = await _client
        .from('favorites')
        .select('recipe_id')
        .eq('user_id', userId);
    return List<String>.from(
      (resp as List).map((e) => e['recipe_id'].toString()),
    );
  }

  @override
  Future<int> getCountForRecipe({required String recipeId}) async {
    final resp = await _client
        .from('favorites')
        .select('favorite_id')
        .eq('recipe_id', recipeId);
    final list = resp as List;
    return list.length;
  }
}
