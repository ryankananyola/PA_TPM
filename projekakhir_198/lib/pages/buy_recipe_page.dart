import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

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
  String? _currentAddress;

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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "Layanan lokasi tidak aktif";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "Izin lokasi ditolak";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Position: ${position.latitude}, ${position.longitude}");

      if (kIsWeb) {
        // Gunakan API Nominatim untuk web
        final url = Uri.parse(
            "https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}");
        final response = await http.get(url, headers: {
          'User-Agent': 'FlutterApp'
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data["address"];
          final city = address["city"] ?? address["town"] ?? address["village"] ?? "";
          final country = address["country"] ?? "";
          setState(() {
            _currentAddress = "$city, $country";
          });
        } else {
          setState(() {
            _currentAddress = "Gagal reverse geocoding (web)";
          });
        }
      } else {
        // Gunakan geocoding native di Android/iOS
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          List<String> parts = [];

          if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
          if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);

          setState(() {
            _currentAddress = parts.join(', ');
          });
        } else {
          setState(() {
            _currentAddress = "Lokasi tidak ditemukan";
          });
        }
      }
    } catch (e) {
      print("Error mendapatkan lokasi: $e");
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi: $e";
      });
    }
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
      location: _currentAddress,
      purchasedAt: DateTime.now(),
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
        title: const Text('Beli Resep'),
        centerTitle: true,
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
            if (_currentAddress != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Lokasi Anda: $_currentAddress",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Ambil Lokasi Saya'),
                onPressed: () async {
                  await _getCurrentLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
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
                              'Berhasil membeli resep seharga ${_getConvertedPrice(widget.recipe.rating).toStringAsFixed(2)} $_selectedCurrency!',
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
