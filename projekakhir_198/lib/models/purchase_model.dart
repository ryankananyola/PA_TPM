import 'package:hive/hive.dart';
import 'recipe_model.dart';

part 'purchase_model.g.dart';

@HiveType(typeId: 3)
class PurchasedRecipe extends HiveObject {
  @HiveField(0)
  final Recipe recipe;

  @HiveField(1)
  final double purchasePrice;

  PurchasedRecipe({
    required this.recipe,
    required this.purchasePrice,
  });
}
