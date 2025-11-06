import 'package:bloc/bloc.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import '../../domain/usecases/get_recipes_usecase.dart';

part 'recipes_state.dart';

class RecipesCubit extends Cubit<RecipesState> {
  final GetRecipesUseCase getRecipes;

  RecipesCubit({required this.getRecipes}) : super(const RecipesState.initial());

  Future<void> loadRecipes({String? type, String? query}) async {
    emit(state.copyWith(status: RecipesStatus.loading));
    try {
      final data = await getRecipes.call(type: type, query: query);
      emit(state.copyWith(status: RecipesStatus.success, recipes: data));
    } catch (e) {
      emit(state.copyWith(status: RecipesStatus.failure, errorMessage: e.toString()));
    }
  }
}
