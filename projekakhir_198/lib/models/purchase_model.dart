import 'package:hive/hive.dart';
import 'recipe_model.dart';

part 'purchase_model.g.dart';

@HiveType(typeId: 3)
class PurchasedRecipe extends HiveObject {
  @HiveField(0)
  final Recipe recipe;

  @HiveField(1)
  final double purchasePrice;

  @HiveField(2)
  final String? location;

  @HiveField(3)
  final DateTime purchasedAt; // waktu pembelian

  PurchasedRecipe({
    required this.recipe,
    required this.purchasePrice,
    this.location,
    required this.purchasedAt,
  });
}
