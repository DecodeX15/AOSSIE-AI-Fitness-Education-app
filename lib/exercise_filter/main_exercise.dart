import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './algo/injury_filter.dart';
import './algo/scoring.dart';

class MainExercise {
  static Future<List<Map<String, dynamic>>> getSessionExercises() async {
    final String jsonString = await rootBundle.loadString(
      'assets/exercise_db.json',
    );
    final String cleaned = jsonString.trimLeft();
    final List<dynamic> decoded = json.decode(cleaned);
    final List<Map<String, dynamic>> allExercises =
        List<Map<String, dynamic>>.from(decoded);
    print("Total exercises: ${allExercises.length}");
    final prefs = await SharedPreferences.getInstance();
    final userInjuries = List<String>.from(
      prefs.getStringList("injuries") ?? [],
    );
    final userGoals = List<String>.from(prefs.getStringList("goals") ?? []);
    final userDifficulty = prefs.getString("level") ?? "beginner";
    final userIntensity = prefs.getString("intensity") ?? "moderate";
    print("User injuries: $userInjuries");
    print("User goals: $userGoals");
    print("User difficulty: $userDifficulty");

    final safeExercises = InjuryFilter.filterByInjury(
      allExercises: allExercises,
      userInjuries: userInjuries,
    );
    print("Safe exercises after injury filter: ${safeExercises.length}");
    final rankedExercises = ExerciseScoring.scoreAndRank(
      safeExercises: safeExercises,
      userGoals: userGoals,
      userDifficulty: userDifficulty,
      userIntensity: userIntensity,
    );
    final lastSessionExercises = Set<String>.from(
      prefs.getStringList("last_7_days_exercises") ?? [],
    );
    print("lass ki lengths ${lastSessionExercises.length}");
    final sessionExercises = lastSessionExercises.isEmpty
        ? rankedExercises
        : rankedExercises
              .where((ex) => !lastSessionExercises.contains(ex["exercise_id"]))
              .toList();

    for (var ex in sessionExercises) {
      print("////////${ex['name']} → score: ${ex['score']}");
    }
    return sessionExercises.take(4).toList();
  }
}
