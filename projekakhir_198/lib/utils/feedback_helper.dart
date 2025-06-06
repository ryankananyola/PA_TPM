import 'package:hive/hive.dart';
import '../models/feedback_model.dart';

class FeedbackHelper {
  static const String boxName = 'feedbackBox';

  static Future<void> addFeedback(FeedbackModel feedback) async {
    final box = await Hive.openBox<FeedbackModel>(boxName);
    await box.add(feedback);
  }

  static Future<void> updateFeedback(int index, FeedbackModel feedback) async {
    final box = await Hive.openBox<FeedbackModel>(boxName);
    await box.putAt(index, feedback);
  }

  static Future<void> deleteFeedback(int index) async {
    final box = await Hive.openBox<FeedbackModel>(boxName);
    await box.deleteAt(index);
  }

  static Future<List<FeedbackModel>> getFeedbacksByRecipe(int recipeId) async {
    final box = await Hive.openBox<FeedbackModel>(boxName);
    return box.values.where((f) => f.recipeId == recipeId).toList();
  }

  static Future<Box<FeedbackModel>> openBox() async {
    return Hive.openBox<FeedbackModel>(boxName);
  }
}
