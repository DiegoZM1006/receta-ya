import '../../domain/model/meal_type.dart';
import '../../domain/repository/meal_type_repository.dart';
import '../source/meal_type_remote_datasource.dart';

class MealTypeRepositoryImpl implements MealTypeRepository {
  final MealTypeRemoteDataSource remote;

  MealTypeRepositoryImpl({required this.remote});

  @override
  Future<List<MealType>> getMealTypes() async {
    return await remote.fetchMealTypes();
  }
}
