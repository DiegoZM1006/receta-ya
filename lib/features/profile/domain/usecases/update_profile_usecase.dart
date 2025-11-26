import 'package:receta_ya/features/profile/data/source/profile_data_source.dart';

class UpdateProfileUseCase {
  final ProfileDataSource dataSource;

  UpdateProfileUseCase({ProfileDataSource? dataSource})
      : dataSource = dataSource ?? ProfileDataSourceImpl();

  Future<void> execute({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    await dataSource.updateProfile(
      userId: userId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
