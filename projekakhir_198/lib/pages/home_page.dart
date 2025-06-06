import 'package:flutter/material.dart';
import '../utils/auth_preferences.dart';
import 'recipe_page.dart';
// import 'help_page.dart';
// import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _loggedInUsername;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthPreferences.getUsername();
    setState(() {
      _loggedInUsername = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          tooltip: 'Logout',
          onPressed: () async {
            await AuthPreferences.logout();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: Text(
          _loggedInUsername != null ? 'Hai, $_loggedInUsername 👋' : 'Selamat Datang',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temukan resep favoritmu dan mulai memasak!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuButton(
                    icon: Icons.restaurant_menu,
                    label: 'Resep',
                    routeName: '/recipes',
                    color: Colors.blue.shade50,
                    iconColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    icon: Icons.help_outline,
                    label: 'Bantuan',
                    routeName: '/help',
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    icon: Icons.info_outline,
                    label: 'Tentang Aplikasi',
                    routeName: '/about',
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required String routeName,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
