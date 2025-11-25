class GeminiRecipe {
  final String name;
  final String description;
  final List<GeminiIngredient> ingredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;
  final String difficulty;
  final double caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatPerServing;

  GeminiRecipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.servings,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
  });
}

class GeminiIngredient {
  final String name;
  final double quantity;
  final String unit;

  GeminiIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}
