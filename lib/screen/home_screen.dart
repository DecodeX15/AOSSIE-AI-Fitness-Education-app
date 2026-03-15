import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/onnx_service.dart';
import '../exercise_filter/main_exercise.dart';
import './main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late OnnxService onnx;
  bool isPreparingSession = false;
  bool modelLoaded = false;
  List<Map<String, dynamic>> sessionExercises = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    print("Step 1: Creating ONNX service");
    onnx = OnnxService();

    print("Step 2: Starting model initialization");

    await onnx.init();

    print("Step 3: Model loaded successfully");
    final exercises = await MainExercise.getSessionExercises();
    setState(() {
      modelLoaded = true;
      sessionExercises = exercises;
    });
    print("Step 4: UI state updated, modelLoaded = true");
  }

  @override
  Widget build(BuildContext context) {
    if (!modelLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    print("Model ready -> rendering Home UI");
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hey Champ ", style: textTheme.headlineMedium),
                const CircleAvatar(radius: 20, child: Icon(Icons.person)),
              ],
            ),

            const SizedBox(height: 24),

            _buildWeekCalendar(textTheme),

            const SizedBox(height: 28),

            Text("Your 4 exercises of today", style: textTheme.titleMedium),

            const SizedBox(height: 16),

            _buildSessionCard(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(TextTheme textTheme) {
    if (isPreparingSession) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              "Preparing your next session...",
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 24),
              const SizedBox(width: 8),
              Text("Today's Session", style: textTheme.titleMedium),
            ],
          ),

          const SizedBox(height: 16),
          ...sessionExercises.map((exercise) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(exercise["name"], style: textTheme.bodyMedium),
                  ),

                  Text(
                    exercise["estimated_duration"],
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MainexerciseScreen(exercises: sessionExercises),
                  ),
                ).then((_) async {
                  final prefs = await SharedPreferences.getInstance();
                  final hasLastSession =
                      prefs.getStringList("last_7_days_exercises") != null;
                  if (hasLastSession) {
                    setState(() => isPreparingSession = true);
                    await Future.delayed(const Duration(seconds: 10));
                    final newExercises =
                        await MainExercise.getSessionExercises();
                    setState(() {
                      sessionExercises = newExercises;
                      isPreparingSession = false;
                    });
                  }
                });
              },
              child: const Text("Start Session"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(TextTheme textTheme) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        bool isSelected = index == 6;

        return Column(
          children: [
            Text(days[index], style: textTheme.labelMedium),

            const SizedBox(height: 6),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : AppColors.card,
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
