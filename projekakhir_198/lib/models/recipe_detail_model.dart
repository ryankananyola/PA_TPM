import 'package:json_annotation/json_annotation.dart';

part 'recipe_detail_model.g.dart';

@JsonSerializable()
class RecipeServiceDetailResponse {
  final List<RecipeServiceDetail> recipes;
  final int total;
  final int skip;
  final int limit;

  RecipeServiceDetailResponse({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory RecipeServiceDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$RecipeServiceDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeServiceDetailResponseToJson(this);
}

@JsonSerializable()
class RecipeServiceDetail {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final int userId;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> mealType;

  RecipeServiceDetail({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.userId,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
  });

  factory RecipeServiceDetail.fromJson(Map<String, dynamic> json) =>
      _$RecipeServiceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeServiceDetailToJson(this);
}
