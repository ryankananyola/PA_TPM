import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/purchase_model.dart';
import 'recipe_detail_screen.dart'; // pastikan halaman ini ada

class PurchasedRecipesPage extends StatefulWidget {
  const PurchasedRecipesPage({Key? key}) : super(key: key);

  @override
  State<PurchasedRecipesPage> createState() => _PurchasedRecipesPageState();
}

class _PurchasedRecipesPageState extends State<PurchasedRecipesPage> {
  late Box<PurchasedRecipe> purchaseBox;

  @override
  void initState() {
    super.initState();
    purchaseBox = Hive.box<PurchasedRecipe>('purchases');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belianku'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: purchaseBox.listenable(),
        builder: (context, Box<PurchasedRecipe> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('Belum ada resep yang dibeli.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final purchased = box.getAt(index)!;
              final recipe = purchased.recipe;

              return GestureDetector(
                onTap: () {
                  // Navigasi ke halaman detail resep
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            recipe.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Harga beli: Rp ${purchased.purchasePrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (purchased.location != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Lokasi: ${purchased.location}',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Dibeli pada: ${DateFormat("dd MMM yyyy, HH:mm").format(purchased.purchasedAt)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
