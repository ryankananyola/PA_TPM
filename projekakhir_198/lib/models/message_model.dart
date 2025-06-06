import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 2)
class Message extends HiveObject {
  @HiveField(0)
  String kesan;

  @HiveField(1)
  String pesan;

  Message({required this.kesan, required this.pesan});
}
