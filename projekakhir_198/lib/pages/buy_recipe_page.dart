import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/recipe_model.dart';
import '../models/recipe_detail_model.dart';
import '../models/purchase_model.dart';


class BuyRecipePage extends StatefulWidget {
  final RecipeServiceDetail recipe;

  const BuyRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<BuyRecipePage> createState() => _BuyRecipePageState();
}

class _BuyRecipePageState extends State<BuyRecipePage> {
  String _selectedCurrency = 'IDR';
  bool _isAlreadyBought = false;

  final Map<String, double> _exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000066,
    'EUR': 0.000061,
  };

  double _calculatePrice(double rating) {
    int steps = ((rating - 1.0) / 0.1).round();
    return 10000 + (steps * 2500);
  }

  double _getConvertedPrice(double rating) {
    double basePrice = _calculatePrice(rating);
    return basePrice * _exchangeRates[_selectedCurrency]!;
  }

  Future<void> _checkIfAlreadyBought() async {
    final box = await Hive.openBox<PurchasedRecipe>('purchases');
    final exists = box.containsKey(widget.recipe.id);
    setState(() {
      _isAlreadyBought = exists;
    });
  }


  Future<void> _saveToHive(double priceInIDR) async {
    final box = await Hive.openBox<PurchasedRecipe>('purchases');

    final recipeToSave = Recipe(
      id: widget.recipe.id,
      name: widget.recipe.name,
      image: widget.recipe.image,
      cuisine: widget.recipe.cuisine,
      rating: widget.recipe.rating,
    );

    final purchasedRecipe = PurchasedRecipe(
      recipe: recipeToSave,
      purchasePrice: priceInIDR,
    );

    await box.put(widget.recipe.id, purchasedRecipe);
  }

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyBought();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beli Resep"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(recipe.image, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            const Text('Pilih Mata Uang:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedCurrency,
              items: _exchangeRates.keys
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Harga: ${_getConvertedPrice(recipe.rating).toStringAsFixed(2)} $_selectedCurrency',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isAlreadyBought
                  ? null
                  : () async {
                      double priceInIDR = _calculatePrice(widget.recipe.rating);
                      await _saveToHive(priceInIDR);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Berhasil membeli resep seharga ${_getConvertedPrice(widget.recipe.rating).toStringAsFixed(2)} $_selectedCurrency!'
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },

                icon: const Icon(Icons.check),
                label: Text(_isAlreadyBought ? "Sudah Dibeli" : "Beli Sekarang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAlreadyBought ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
