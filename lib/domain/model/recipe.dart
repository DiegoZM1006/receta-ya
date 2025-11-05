class Recipe {
  final String id;
  final String name;
  final String? description;
  final double? caloriesPerPortion; 
  final int? proteinsPerPortion; 
  final int? carbsPerPortion; 
  final int? fatsPerPortion; 
  final int? prepTimeMinutes; 
  final String? difficulty; 
  final String? imageUrl;
  final String? instructions; 
  final int? baseServings; 
  final DateTime? createdAt; 
  final String? type;
  final List<String> types; 

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.caloriesPerPortion,
    this.proteinsPerPortion,
    this.carbsPerPortion,
    this.fatsPerPortion,
    this.prepTimeMinutes,
    this.difficulty,
    this.imageUrl,
    this.instructions,
    this.baseServings,
    this.createdAt,
    this.type,
    this.types = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Recipe(
      id: (json['recipe_id'] ?? json['id_receta'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nombre'] ?? '').toString(),
      description: json['description'] as String? ?? json['descripcion'] as String?,
      caloriesPerPortion: _toDouble(json['calories_per_serving'] ?? json['calorias_por_porcion'] ?? json['kcal']),
      proteinsPerPortion: _toInt(json['protein_per_serving'] ?? json['proteinas_por_porcion']),
      carbsPerPortion: _toInt(json['carbs_per_serving'] ?? json['carbohidratos_por_porcion']),
      fatsPerPortion: _toInt(json['fat_per_serving'] ?? json['grasas_por_porcion']),
      prepTimeMinutes: _toInt(json['prep_time'] ?? json['tiempo_preparacion']),
      difficulty: json['difficulty'] as String? ?? json['dificultad'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imagen_url'] as String?,
      instructions: json['instructions'] as String? ?? json['instrucciones'] as String?,
      baseServings: _toInt(json['base_servings'] ?? json['porciones_base']),
      createdAt: _toDate(json['created_at'] ?? json['fecha_creacion']),
      type: json['type'] as String? ?? json['tipo'] as String?,
      types: const [],
    );
  }
}
