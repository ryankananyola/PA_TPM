import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projekakhir_198_181/models/recipe_model.dart';
import 'package:projekakhir_198_181/models/recipe_detail_model.dart';
import 'package:projekakhir_198_181/services/recipe_service.dart';
import 'feedback_page.dart';
import '../models/feedback_model.dart';
import 'buy_recipe_page.dart';
import 'package:intl/intl.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late Future<RecipeServiceDetail> _recipeDetailFuture;
  late TabController _tabController;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _recipeDetailFuture = RecipeService.fetchRecipeDetail(widget.recipeId);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final box = Hive.box<Recipe>('favorites');
    final isFav = box.values.any((r) => r.id == widget.recipeId);
    setState(() {
      isFavorite = isFav;
    });
  }

  void _toggleFavorite(RecipeServiceDetail detail) {
    final box = Hive.box<Recipe>('favorites');
    final recipe = Recipe(
      id: detail.id,
      name: detail.name,
      image: detail.image,
      cuisine: detail.cuisine,
      rating: detail.rating,
    );

    String message;

    if (isFavorite) {
      final existingKey = box.keys.firstWhere(
        (key) => box.get(key)!.id == recipe.id,
        orElse: () => null,
      );
      if (existingKey != null) {
        box.delete(existingKey);
      }
      message = 'Dihapus dari favorit';
    } else {
      box.add(recipe);
      message = 'Ditambahkan ke favorit';
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RecipeServiceDetail>(
        future: _recipeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final recipe = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                    onPressed: () => _toggleFavorite(recipe),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      recipe.name,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(recipe.image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black26],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'Informasi'),
                        Tab(text: 'Bahan'),
                        Tab(text: 'Langkah'),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 320,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInfoTab(recipe),
                          _buildIngredientsTab(recipe),
                          _buildInstructionsTab(recipe),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(RecipeServiceDetail recipe) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.access_time, 'Durasi: ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} menit'),
                  const Divider(),
                  _infoRow(Icons.people, 'Porsi: ${recipe.servings} orang'),
                  const Divider(),
                  _infoRow(Icons.bolt, 'Tingkat: ${recipe.difficulty}'),
                  const Divider(),
                  _infoRow(Icons.restaurant, 'Masakan: ${recipe.cuisine}'),
                  const Divider(),
                  _infoRow(Icons.local_fire_department, 'Kalori/porsi: ${recipe.caloriesPerServing} kkal'),
                  const Divider(),
                  _infoRow(Icons.star, 'Rating: ${recipe.rating} ⭐ (${recipe.reviewCount} review)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tag:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: recipe.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackPage(
                    recipeId: recipe.id,
                    recipeImage: recipe.image,
                    recipeTitle: recipe.name,
                    recipeCity: recipe.cuisine,
                    onSubmit: (feedback) {
                      final box = Hive.box<FeedbackModel>('feedbacks');
                      box.add(feedback);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback terkirim!')),
                      );
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.feedback),
            label: const Text('Kirim Catatan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyRecipePage(recipe: recipe),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Beli Resep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Daftar Catatan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildFeedbackList(recipe.id),
        ],
      ),
    );
  }

  int getTimezoneOffset(String timezone) {
    switch (timezone) {
      case 'WITA':
        return 8;
      case 'WIT':
        return 9;
      case 'London':
        return 1;
      case 'WIB':
      default:
        return 7;
    }
  }

  
  Widget _buildFeedbackList(int recipeId) {
    final box = Hive.box<FeedbackModel>('feedbacks');

    return ValueListenableBuilder<Box<FeedbackModel>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        final feedbackList = box.values
            .where((f) => f.recipeId == recipeId)
            .toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        if (feedbackList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Belum ada catatan.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: feedbackList.map((f) {
            final offset = getTimezoneOffset(f.timezone);
            final convertedTime = f.submittedAt.toUtc().add(Duration(hours: offset));
            final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(convertedTime);
            final timeStr = '$formattedTime (${f.timezone})';


            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(f.comment),
                subtitle: Text(timeStr),
                leading: const Icon(Icons.notes),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () async {
                        final controller = TextEditingController(text: f.comment);
                        final newComment = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Catatan"),
                            content: TextField(
                              controller: controller,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Edit catatan...',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, controller.text.trim()),
                                child: const Text('Simpan'),
                              ),
                            ],
                          ),
                        );

                        if (newComment != null && newComment.isNotEmpty) {
                          f.comment = newComment;
                          await f.save();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Catatan'),
                            content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await f.delete();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIngredientsTab(RecipeServiceDetail recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: recipe.ingredients.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.circle, size: 10),
            title: Text(recipe.ingredients[index]),
          );
        },
      ),
    );
  }

  Widget _buildInstructionsTab(RecipeServiceDetail recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: recipe.instructions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(recipe.instructions[index]),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
