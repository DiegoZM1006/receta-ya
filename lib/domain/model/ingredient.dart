class Ingredient {
  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double? caloriesPerUnit;

  Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    this.caloriesPerUnit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return Ingredient(
      id: (json['ingredient_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nombre'] ?? '').toString(),
      unit: (json['unit'] ?? json['unidad'] ?? '').toString(),
      quantity: _toDouble(json['base_quantity'] ?? json['quantity'] ?? json['cantidad'] ?? 0) ?? 0.0,
      caloriesPerUnit: _toDouble(json['calories_per_unit'] ?? json['calorias_por_unidad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': id,
      'name': name,
      'unit': unit,
      'base_quantity': quantity,
      'calories_per_unit': caloriesPerUnit,
    };
  }
}

