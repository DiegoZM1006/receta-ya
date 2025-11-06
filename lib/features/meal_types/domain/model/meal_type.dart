class MealType {
  final String id;
  final String name;

  MealType({required this.id, required this.name});

  factory MealType.fromJson(Map<String, dynamic> json) {
    final id = (json['meal_type_id'] ?? json['id'] ?? json['mealTypeId'])?.toString() ?? '';
    final name = (json['name'] ?? json['nombre'])?.toString() ?? '';
    return MealType(id: id, name: name);
  }
}
