import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Recipe {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final String cuisine;

  @HiveField(4)
  final double rating;

  Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.rating,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class RecipeList {
  final List<Recipe> recipes;

  RecipeList({required this.recipes});

  factory RecipeList.fromJson(Map<String, dynamic> json) =>
      _$RecipeListFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeListToJson(this);
}
