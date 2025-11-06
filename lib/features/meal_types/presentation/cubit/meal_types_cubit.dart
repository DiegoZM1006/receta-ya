import 'package:bloc/bloc.dart';
import '../../domain/model/meal_type.dart';
import '../../domain/usecases/get_meal_types_usecase.dart';

part 'meal_types_state.dart';

class MealTypesCubit extends Cubit<MealTypesState> {
  final GetMealTypesUseCase getMealTypes;

  MealTypesCubit({required this.getMealTypes}) : super(const MealTypesState.initial());

  Future<void> loadMealTypes() async {
    emit(state.copyWith(status: MealTypesStatus.loading));
    try {
      final data = await getMealTypes.call();
      emit(state.copyWith(status: MealTypesStatus.success, mealTypes: data));
    } catch (e) {
      emit(state.copyWith(status: MealTypesStatus.failure, errorMessage: e.toString()));
    }
  }
}
