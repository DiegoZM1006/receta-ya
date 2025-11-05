import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/domain/model/recipe.dart';

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

}
