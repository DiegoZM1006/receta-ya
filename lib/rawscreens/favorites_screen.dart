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
      appBar: AppBar(
        title: Text('Favoritos', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
          ? Center(
              child: Text(
                'No hay recetas en favoritos',
                style: GoogleFonts.poppins(),
              ),
            )
          : ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final r = _recipes[index];
                return ListTile(
                  title: Text(r.name, style: GoogleFonts.poppins()),
                  subtitle: Text(
                    r.description ?? '',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: r.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
