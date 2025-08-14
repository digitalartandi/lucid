import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_models.dart';

class QuizRepo {
  static Future<Quiz> load(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return Quiz.fromJson(jsonDecode(raw));
  }

  static Future<void> saveScore(String quizId, int score, int total) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('quiz.$quizId', '$score/$total');
  }

  static Future<String?> getScore(String quizId) async {
    final p = await SharedPreferences.getInstance();
    return p.getString('quiz.$quizId');
  }
}
