import 'package:receta_ya/features/favorites/domain/repository/favorites_repository.dart';

class GetUserFavoritesUseCase {
  final FavoritesRepository repository;
  GetUserFavoritesUseCase(this.repository);

  Future<List<String>> execute({required String userId}) {
    return repository.getFavoritesByUser(userId: userId);
  }
}
