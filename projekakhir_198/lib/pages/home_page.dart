import 'package:flutter/material.dart';
import '../utils/auth_preferences.dart';
import 'recipe_page.dart';
import 'profile_page.dart';
import 'kesanpesan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _loggedInUsername;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    RecipePage(),
    KesanPesanPage(),
    ProfilePage(),
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
            await AuthPreferences.logout(_loggedInUsername);
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Kesan & Pesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
