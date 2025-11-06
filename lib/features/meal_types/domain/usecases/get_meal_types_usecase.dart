import '../model/meal_type.dart';
import '../repository/meal_type_repository.dart';

class GetMealTypesUseCase {
  final MealTypeRepository repository;

  GetMealTypesUseCase(this.repository);

  Future<List<MealType>> call() async {
    return repository.getMealTypes();
  }
}
