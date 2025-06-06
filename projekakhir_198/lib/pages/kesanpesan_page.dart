import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';

class KesanPesanPage extends StatefulWidget {
  const KesanPesanPage({super.key});

  @override
  State<KesanPesanPage> createState() => _KesanPesanPageState();
}

class _KesanPesanPageState extends State<KesanPesanPage> {
  final Box<Message> _messageBox = Hive.box<Message>('messagesBox');

  void _showForm({Message? existingMessage}) {
    final kesanController = TextEditingController(text: existingMessage?.kesan ?? '');
    final pesanController = TextEditingController(text: existingMessage?.pesan ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingMessage == null ? 'Tambah Kesan/Pesan' : 'Edit Kesan/Pesan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kesanController,
                decoration: const InputDecoration(hintText: 'Tulis kesan...'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pesanController,
                decoration: const InputDecoration(hintText: 'Tulis pesan...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final kesan = kesanController.text.trim();
              final pesan = pesanController.text.trim();

              if (kesan.isEmpty || pesan.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kesan dan Pesan tidak boleh kosong!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              try {
                if (existingMessage != null) {
                  existingMessage.kesan = kesan;
                  existingMessage.pesan = pesan;
                  await existingMessage.save();
                } else {
                  await _messageBox.add(Message(kesan: kesan, pesan: pesan));
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kesan & Pesan berhasil disimpan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Gagal menyimpan: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terjadi kesalahan saat menyimpan.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await message.delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: ValueListenableBuilder(
        valueListenable: _messageBox.listenable(),
        builder: (context, Box<Message> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('Belum ada kesan atau pesan.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final message = box.getAt(index);
              if (message == null) return const SizedBox();
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: Text('Kesan: ${message.kesan}'),
                  subtitle: Text('Pesan: ${message.pesan}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showForm(existingMessage: message),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMessage(message),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
