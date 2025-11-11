import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/domain/model/ingredient.dart';

class RecipeRemoteDataSource {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Recipe>> fetchRecipes({String? type, String? query}) async {
  final tableName = 'recipes';

    List<dynamic>? recipeRows;

    if (type != null && type.isNotEmpty && type != 'Todas') {
      final tipoRes = await client.from('meal_types').select('meal_type_id').ilike('name', type);
      final tipoList = List<dynamic>.from(tipoRes as List? ?? []);
      if (tipoList.isEmpty) return <Recipe>[];
      final tipoId = tipoList.first['meal_type_id'];

      final mapRes = await client.from('recipe_meal_types').select('recipe_id').eq('meal_type_id', tipoId);
      final mapList = List<dynamic>.from(mapRes as List? ?? []);
      final ids = mapList.map((e) => e['recipe_id'].toString()).toList();
      if (ids.isEmpty) return <Recipe>[];

      final List<dynamic> rows = [];
      for (var id in ids) {
        var q = client.from(tableName).select().eq('recipe_id', id);
        if (query != null && query.trim().isNotEmpty) {
          q = q.ilike('name', '%${query.trim()}%');
        }
        final r = await q.order('name', ascending: true);
        rows.addAll(List<dynamic>.from(r as List));
      }
      recipeRows = rows;
    } else {
      var q = client.from(tableName).select();
      if (query != null && query.trim().isNotEmpty) {
        q = q.ilike('name', '%${query.trim()}%');
      }
      recipeRows = List<dynamic>.from(await q.order('name', ascending: true) as List? ?? []);
    }

  final recipes = recipeRows.map((e) => Recipe.fromJson(Map<String, dynamic>.from(e))).toList();

    final recipeIds = recipes.map((r) => r.id).toList();
    if (recipeIds.isNotEmpty) {
  final allMaps = List<dynamic>.from(await client.from('recipe_meal_types').select('recipe_id, meal_type_id') as List? ?? []);
  final maps = allMaps.where((m) => recipeIds.contains(m['recipe_id'].toString())).toList();
  final tipoIds = maps.map((m) => m['meal_type_id'].toString()).toSet().toList();
  final allTipos = List<dynamic>.from(await client.from('meal_types').select('meal_type_id, name') as List? ?? []);
  final tipos = allTipos.where((t) => tipoIds.contains(t['meal_type_id'].toString())).toList();

      final Map<String, String> tipoMap = {};
      for (var t in tipos) {
        tipoMap[t['meal_type_id'].toString()] = t['name'].toString();
      }

      final Map<String, List<String>> recipeToTypes = {};
      for (var m in maps) {
        final rid = m['recipe_id'].toString();
        final tid = m['meal_type_id'].toString();
        recipeToTypes.putIfAbsent(rid, () => []).add(tipoMap[tid] ?? tid);
      }

      for (var i = 0; i < recipes.length; i++) {
        final r = recipes[i];
        final typesFor = recipeToTypes[r.id] ?? [];
        recipes[i] = Recipe(
          id: r.id,
          name: r.name,
          description: r.description,
          caloriesPerPortion: r.caloriesPerPortion,
          proteinsPerPortion: r.proteinsPerPortion,
          carbsPerPortion: r.carbsPerPortion,
          fatsPerPortion: r.fatsPerPortion,
          prepTimeMinutes: r.prepTimeMinutes,
          difficulty: r.difficulty,
          imageUrl: r.imageUrl,
          instructions: r.instructions,
          baseServings: r.baseServings,
          createdAt: r.createdAt,
          type: r.type,
          types: typesFor,
        );
      }
    }

    return recipes;
  }

  Future<Recipe> fetchRecipeById(String recipeId) async {
    // Obtener la receta principal
    final recipeRes = await client
        .from('recipes')
        .select()
        .eq('recipe_id', recipeId)
        .single();

    final recipeData = Map<String, dynamic>.from(recipeRes);
    final recipe = Recipe.fromJson(recipeData);

    // Obtener ingredientes de la receta con join a la tabla ingredients
    final ingredientsRes = await client
        .from('recipe_ingredients')
        .select('''
          base_quantity,
          ingredients (
            ingredient_id,
            name,
            unit,
            calories_per_unit
          )
        ''')
        .eq('recipe_id', recipeId);

    final ingredientsList = List<dynamic>.from(ingredientsRes as List? ?? []);
    final List<Ingredient> ingredients = [];

    for (var item in ingredientsList) {
      final ingredientData = item['ingredients'];
      if (ingredientData != null) {
        final ingredientMap = Map<String, dynamic>.from(ingredientData);
        ingredientMap['base_quantity'] = item['base_quantity'];
        ingredients.add(Ingredient.fromJson(ingredientMap));
      }
    }

    // Obtener tipos de comida relacionados
    final mealTypesRes = await client
        .from('recipe_meal_types')
        .select('meal_type_id')
        .eq('recipe_id', recipeId);

    final mealTypeIds = List<dynamic>.from(mealTypesRes as List? ?? [])
        .map((e) => e['meal_type_id'].toString())
        .toList();

    final List<String> types = [];
    if (mealTypeIds.isNotEmpty) {
      final allMealTypes = await client
          .from('meal_types')
          .select('meal_type_id, name');

      final allMealTypesList = List<dynamic>.from(allMealTypes as List? ?? []);
      for (var mt in allMealTypesList) {
        if (mealTypeIds.contains(mt['meal_type_id'].toString())) {
          types.add(mt['name'].toString());
        }
      }
    }

    // Construir la receta completa con ingredientes y tipos
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      description: recipe.description,
      caloriesPerPortion: recipe.caloriesPerPortion,
      proteinsPerPortion: recipe.proteinsPerPortion,
      carbsPerPortion: recipe.carbsPerPortion,
      fatsPerPortion: recipe.fatsPerPortion,
      prepTimeMinutes: recipe.prepTimeMinutes,
      difficulty: recipe.difficulty,
      imageUrl: recipe.imageUrl,
      instructions: recipe.instructions,
      baseServings: recipe.baseServings,
      createdAt: recipe.createdAt,
      type: recipe.type,
      types: types,
      ingredients: ingredients,
    );
  }

}
