import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:receta_ya/features/favorites/domain/usecases/get_user_favorites_usecase.dart';
import 'package:receta_ya/features/recipes/data/source/recipe_remote_datasource.dart';
import 'package:receta_ya/features/recipes/data/repository/recipe_repository_impl.dart';
import 'package:receta_ya/features/recipes/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/rawscreens/recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favRepo = FavoritesRepositoryImpl();
  late final GetUserFavoritesUseCase _getUserFavorites;
  late final GetRecipeByIdUseCase _getRecipeById;
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getUserFavorites = GetUserFavoritesUseCase(_favRepo);
    _getRecipeById = GetRecipeByIdUseCase(
      RecipeRepositoryImpl(remote: RecipeRemoteDataSource()),
    );
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final ids = await _getUserFavorites.execute(userId: user.id);
      final List<Recipe> loaded = [];
      for (final id in ids) {
        try {
          final r = await _getRecipeById.call(id);
          loaded.add(r);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _recipes = loaded;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Favoritos',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _loading ? 'Cargando...' : '${_recipes.length} receta${_recipes.length == 1 ? '' : 's'}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey[300], thickness: 1),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _recipes.isEmpty
                  ? Center(
                      child: Text(
                        'No hay recetas en favoritos',
                        style: GoogleFonts.poppins(),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final r = _recipes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipeId: r.id),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r.description ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                          const SizedBox(width: 6),
                                          Text('${r.caloriesPerPortion?.toInt() ?? 0} kcal', style: GoogleFonts.poppins(fontSize: 12)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text('${r.prepTimeMinutes ?? 0} min', style: GoogleFonts.poppins(fontSize: 12)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(r.difficulty ?? 'N/A', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
