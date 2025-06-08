import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  // Key untuk status login dan user
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUsername = 'username';

  /// Simpan status login
  static Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  /// Ambil status login
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Ambil username yang sedang login
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Logout user (hapus data login tapi jangan hapus user yang sudah terdaftar)
  static Future<void> logout(String? username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }

  /// Simpan user baru (dengan nama & nim)
  static Future<void> registerUser(String username, String password, String nama, String nim) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'username': username,
      'password': password,
      'nama': nama,
      'nim': nim,
    };
    await prefs.setString('user_$username', jsonEncode(userData));
  }

  /// Validasi username dan password
  static Future<bool> validateUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_$username');
    if (userJson == null) return false;
    final userData = jsonDecode(userJson);
    return userData['password'] == password;
  }

  /// Ambil data user berdasarkan username
  static Future<Map<String, String>?> getUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_$username');
    if (userJson == null) return null;
    final userData = jsonDecode(userJson);
    return {
      'nama': userData['nama'] ?? '',
      'nim': userData['nim'] ?? '',
    };
  }

  /// Simpan foto profil mobile berdasarkan username (path file lokal)
  static Future<void> saveProfilePictureByUsername(String username, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_pic_$username', path);
  }

  /// Ambil foto profil mobile berdasarkan username (path file lokal)
  static Future<String?> getProfilePictureByUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_pic_$username');
  }

  /// Simpan foto profil web berdasarkan username (base64 string)
  static Future<void> saveProfilePictureWebByUsername(String username, List<int> bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = base64Encode(bytes);
    await prefs.setString('profile_pic_web_$username', base64Image);
  }

  /// Ambil foto profil web berdasarkan username (base64 string)
  static Future<String?> getProfilePictureWebBase64ByUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_pic_web_$username');
  }
}
