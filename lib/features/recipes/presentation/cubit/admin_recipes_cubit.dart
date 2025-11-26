import 'package:bloc/bloc.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import '../../domain/usecases/create_recipe_usecase.dart';
import '../../domain/usecases/update_recipe_usecase.dart';
import '../../domain/usecases/delete_recipe_usecase.dart';

part 'admin_recipes_state.dart';

class AdminRecipesCubit extends Cubit<AdminRecipesState> {
  final CreateRecipeUseCase createRecipe;
  final UpdateRecipeUseCase updateRecipe;
  final DeleteRecipeUseCase deleteRecipe;

  AdminRecipesCubit({
    required this.createRecipe,
    required this.updateRecipe,
    required this.deleteRecipe,
  }) : super(const AdminRecipesState.initial());

  Future<void> createNewRecipe(Recipe recipe, List<String> mealTypeIds) async {
    emit(state.copyWith(status: AdminRecipesStatus.loading));
    try {
      await createRecipe.call(recipe, mealTypeIds);
      emit(state.copyWith(
        status: AdminRecipesStatus.success,
        successMessage: 'Receta "${recipe.name}" creada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminRecipesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateExistingRecipe(
    String recipeId,
    Recipe recipe,
    List<String> mealTypeIds,
  ) async {
    emit(state.copyWith(status: AdminRecipesStatus.loading));
    try {
      await updateRecipe.call(recipeId, recipe, mealTypeIds);
      emit(state.copyWith(
        status: AdminRecipesStatus.success,
        successMessage: 'Receta "${recipe.name}" actualizada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminRecipesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteExistingRecipe(String recipeId) async {
    emit(state.copyWith(status: AdminRecipesStatus.loading));
    try {
      await deleteRecipe.call(recipeId);
      emit(state.copyWith(
        status: AdminRecipesStatus.success,
        successMessage: 'Receta eliminada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminRecipesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void resetState() {
    emit(const AdminRecipesState.initial());
  }
}
