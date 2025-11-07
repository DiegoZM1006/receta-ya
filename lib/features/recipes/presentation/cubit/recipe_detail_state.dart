part of 'recipe_detail_cubit.dart';

enum RecipeDetailStatus { initial, loading, success, failure }

class RecipeDetailState {
  final RecipeDetailStatus status;
  final Recipe? recipe;
  final String? errorMessage;

  const RecipeDetailState._({
    required this.status,
    this.recipe,
    this.errorMessage,
  });

  const RecipeDetailState.initial() : this._(status: RecipeDetailStatus.initial);

  RecipeDetailState copyWith({
    RecipeDetailStatus? status,
    Recipe? recipe,
    String? errorMessage,
  }) {
    return RecipeDetailState._(
      status: status ?? this.status,
      recipe: recipe ?? this.recipe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

