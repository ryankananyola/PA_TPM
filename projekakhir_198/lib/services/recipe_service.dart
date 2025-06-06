import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../models/recipe_detail_model.dart'; // ✅ tambahkan ini

class RecipeService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final recipeList = RecipeList.fromJson(data);
      return recipeList.recipes;
    } else {
      throw Exception('Gagal memuat data resep');
    }
  }

  static Future<RecipeServiceDetail> fetchRecipeDetail(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/$id'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return RecipeServiceDetail.fromJson(data);
  } else {
    throw Exception('Gagal memuat detail resep');
  }
}

}
