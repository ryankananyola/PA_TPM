import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/recipe_model.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/kesanpesan_page.dart';
import 'pages/profile_page.dart';
import 'pages/recipe_page.dart';
import 'pages/favorite_page.dart';
import 'pages/splash_page.dart';
import 'models/feedback_model.dart';
import 'models/message_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive dan buka box favorit
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('favorites');
  Hive.registerAdapter(FeedbackModelAdapter());
  await Hive.openBox<FeedbackModel>('feedbacks');
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>('messagesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restoran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 219, 243, 255),
      ),
      routes: {
        '/splash' : (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/recipes': (context) => const RecipePage(),
        '/kesanpesan': (context) => const KesanPesanPage(),
        '/profile': (context) => const ProfilePage(),
        '/favorites': (context) => const FavoritePage(),
      },
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const RecipePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
