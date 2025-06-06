import 'package:hive/hive.dart';
import '../models/recipe_model.dart';

class FavoriteHelper {
  static const String boxName = 'favorites';

  static Future<void> addFavorite(Recipe recipe) async {
    final box = await Hive.openBox<Recipe>(boxName);
    await box.put(recipe.id, recipe);
  }

  static Future<void> removeFavorite(int id) async {
    final box = await Hive.openBox<Recipe>(boxName);
    await box.delete(id);
  }

  static Future<List<Recipe>> getAllFavorites() async {
    final box = await Hive.openBox<Recipe>(boxName);
    return box.values.toList();
  }

  static bool isFavorite(int id) {
    final box = Hive.box<Recipe>(boxName);
    return box.containsKey(id);
  }
}
