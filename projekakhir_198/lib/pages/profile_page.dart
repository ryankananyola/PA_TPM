import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../utils/auth_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _nama;
  String? _nim;
  String? _username;
  String? _profilePicPath;
  Uint8List? _profilePicBytes; // Untuk web image preview

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await AuthPreferences.getUsername();
    if (username != null) {
      final userData = await AuthPreferences.getUserData(username);

      if (kIsWeb) {
        final base64Image = await AuthPreferences.getProfilePictureWebBase64ByUsername(username);
        if (base64Image != null && base64Image.isNotEmpty) {
          try {
            final bytes = base64Decode(base64Image);
            setState(() {
              _username = username;
              _nama = userData?['nama'];
              _nim = userData?['nim'];
              _profilePicBytes = bytes;
              _profilePicPath = null;
            });
            return;
          } catch (e) {
            print('Error decode base64 image: $e');
          }
        }
      }


      final profilePicPath = await AuthPreferences.getProfilePictureByUsername(username);
      setState(() {
        _username = username;
        _nama = userData?['nama'];
        _nim = userData?['nim'];
        _profilePicPath = profilePicPath;
        _profilePicBytes = null;
      });
    }
  }


  Future<void> _pickProfileImage() async {
    if (kIsWeb) {
      // Untuk web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        setState(() {
          _profilePicBytes = bytes;
          _profilePicPath = null; // reset path karena di web pakai bytes
        });
      }
    } else {
      // Mobile: pakai image_picker dan file system
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _profilePicPath = file.path;
          _profilePicBytes = null;
        });
      }
    }
  }

  Future<void> _saveProfileImage() async {
    if (_username == null) return;

    if (kIsWeb) {
      if (_profilePicBytes != null) {
        print('Saving profile pic for web user $_username');
        await AuthPreferences.saveProfilePictureWebByUsername(_username!, _profilePicBytes!);
        print('Saved base64 image');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil disimpan.')),
        );
      } else {
        print('No profilePicBytes to save');
      }
    } else {
      if (_profilePicPath != null) {
        print('Saving profile pic for mobile user $_username at $_profilePicPath');
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_profilePicPath!);
        final savedImage = await File(_profilePicPath!).copy('${directory.path}/$fileName');

        await AuthPreferences.saveProfilePictureByUsername(_username!, savedImage.path);
        setState(() {
          _profilePicPath = savedImage.path;
        });
        print('Saved image at ${savedImage.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil disimpan.')),
        );
      } else {
        print('No profilePicPath to save');
      }
    }
  }


  void _logout() async {
    await AuthPreferences.logout(_username);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_profilePicPath != null) {
      imageProvider = FileImage(File(_profilePicPath!));
    } else if (_profilePicBytes != null) {
      imageProvider = MemoryImage(_profilePicBytes!);
    }

    return Scaffold(
      body: _nama == null || _nim == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nama ?? '-',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('NIM: $_nim', style: const TextStyle(fontSize: 16)),
                  Text('Username: $_username', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveProfileImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _logout,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
