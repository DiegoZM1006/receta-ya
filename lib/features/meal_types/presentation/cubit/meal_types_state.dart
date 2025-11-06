part of 'meal_types_cubit.dart';

enum MealTypesStatus { initial, loading, success, failure }

class MealTypesState {
  final MealTypesStatus status;
  final List<MealType> mealTypes;
  final String? errorMessage;

  const MealTypesState._({required this.status, required this.mealTypes, this.errorMessage});

  const MealTypesState.initial() : this._(status: MealTypesStatus.initial, mealTypes: const []);

  MealTypesState copyWith({MealTypesStatus? status, List<MealType>? mealTypes, String? errorMessage}) {
    return MealTypesState._(
      status: status ?? this.status,
      mealTypes: mealTypes ?? this.mealTypes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
