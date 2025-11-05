import '../model/meal_type.dart';

abstract class MealTypeRepository {
  Future<List<MealType>> getMealTypes();
}
