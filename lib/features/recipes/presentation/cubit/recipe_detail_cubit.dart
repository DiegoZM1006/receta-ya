import 'package:bloc/bloc.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import '../../domain/usecases/get_recipe_by_id_usecase.dart';

part 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final GetRecipeByIdUseCase getRecipeById;

  RecipeDetailCubit({required this.getRecipeById}) : super(const RecipeDetailState.initial());

  Future<void> loadRecipeById(String recipeId) async {
    emit(state.copyWith(status: RecipeDetailStatus.loading));
    try {
      final recipe = await getRecipeById.call(recipeId);
      emit(state.copyWith(status: RecipeDetailStatus.success, recipe: recipe));
    } catch (e) {
      emit(state.copyWith(status: RecipeDetailStatus.failure, errorMessage: e.toString()));
    }
  }
}

