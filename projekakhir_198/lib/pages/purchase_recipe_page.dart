import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/purchase_model.dart'; // sesuaikan path-nya

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
        title: const Text('Resep yang Dibeli'),
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final purchased = box.getAt(index)!;
              final recipe = purchased.recipe;

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recipe.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Harga beli: Rp ${purchased.purchasePrice.toStringAsFixed(0)}'),
                onTap: () {
                  // Bisa tambahkan navigasi ke detail resep jika perlu
                },
              );
            },
          );
        },
      ),
    );
  }
}
