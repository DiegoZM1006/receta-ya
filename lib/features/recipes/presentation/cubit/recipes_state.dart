part of 'recipes_cubit.dart';

enum RecipesStatus { initial, loading, success, failure }

class RecipesState {
  final RecipesStatus status;
  final List<Recipe> recipes;
  final String? errorMessage;

  const RecipesState._({
    required this.status,
    required this.recipes,
    this.errorMessage,
  });

  const RecipesState.initial() : this._(status: RecipesStatus.initial, recipes: const []);

  RecipesState copyWith({RecipesStatus? status, List<Recipe>? recipes, String? errorMessage}) {
    return RecipesState._(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
