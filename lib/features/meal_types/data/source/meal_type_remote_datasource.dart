import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/meal_type.dart';

class MealTypeRemoteDataSource {
  final SupabaseClient client = Supabase.instance.client;

  /// Fetch all meal types ordered by name
  Future<List<MealType>> fetchMealTypes() async {
    final res = await client.from('meal_types').select('meal_type_id, name').order('name', ascending: true) as List?;
    final list = List<dynamic>.from(res ?? []);
    return list.map((e) => MealType.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
