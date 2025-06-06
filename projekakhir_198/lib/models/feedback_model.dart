import 'package:hive/hive.dart';

part 'feedback_model.g.dart';

@HiveType(typeId: 1)
class FeedbackModel extends HiveObject {
  @HiveField(0)
  final int recipeId;

  @HiveField(1)
  String comment;

  @HiveField(2)
  DateTime submittedAt; // waktu pengiriman

  @HiveField(3)
  String timezone; // zona waktu (WIB, WITA, WIT, London)

  FeedbackModel({
    required this.recipeId,
    required this.comment,
    required this.submittedAt,
    required this.timezone,
  });
}
