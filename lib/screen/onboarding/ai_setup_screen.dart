import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import '../../services/storage_service.dart';
import '../../data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/onnx_service.dart';
import '../../services/tokenizer_service.dart';
import '../../services/allembeddings.dart';
import '../../services/tags_generations.dart';
import 'package:lottie/lottie.dart';

class AiSetupScreen extends StatefulWidget {
  const AiSetupScreen({super.key});

  @override
  State<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends State<AiSetupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  final List<_StepItem> _steps = [
    _StepItem('Analysing your goals...'),
    _StepItem('Understanding your body...'),
    _StepItem('Building your workout routine...'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _runSteps();
  }

  Future<List<String>> _runModel(String text) async {
    final onnx = OnnxService();
    await onnx.init();
    final tokenizer = TokenizerService();
    await tokenizer.init();
    final store = EmbeddingStore();
    await store.init();
    final tagGen = TagsGenerations(onnx, tokenizer, store);
    final tags = await tagGen.getBestTags(text);
    return tags;
  }

  Future<void> _processCustomInputs() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyProcessed = prefs.getBool("ai_onboarding_done") ?? false;
    if (alreadyProcessed) {
      print("already processed here");
      return;
    }
    print("AI onboarding running first time.");
    if (userData["custom_goal"] != null &&
        userData["custom_goal"].toString().isNotEmpty) {
      print("Previous Goals: ${userData["goals"]}");
      final tags = await _runModel(userData["custom_goal"]);
      print("Model response: $tags");
      final goalTags = tags.take(3).toList();
      List<String> goals = List<String>.from(userData["goals"] ?? []);
      goals.addAll(goalTags);
      goals = goals
          .map((e) => e.toLowerCase().replaceAll(" ", "_"))
          .toSet()
          .toList();
      userData["goals"] = goals;
      print("Updated Goals: ${userData["goals"]}");
    }

    if (userData["custom_injury"] != null &&
        userData["custom_injury"].toString().isNotEmpty) {
      print("Previous Injuries: ${userData["injuries"]}");
      final tags = await _runModel(userData["custom_injury"]);
      print("Model response: $tags");
      final injuryTags = tags.sublist(3, 6);
      List<String> injuries = List<String>.from(userData["injuries"] ?? []);
      injuries.addAll(injuryTags);
      injuries = injuries
          .map((e) => e.toLowerCase().replaceAll(" ", "_"))
          .toSet()
          .toList();
      userData["injuries"] = injuries;
      print("Updated Injuries: ${userData["injuries"]}");
    }

    if (userData["custom_motivation"] != null &&
        userData["custom_motivation"].toString().isNotEmpty) {
      print("Previous Motivation: ${userData["motivation"]}");
      final tags = await _runModel(userData["custom_motivation"]);
      print("Model response: $tags");
      final motivationTags = tags.sublist(6, 9);
      List<String> motivation = List<String>.from(userData["motivation"] ?? []);
      motivation.addAll(motivationTags);
      motivation = motivation
          .map((e) => e.toLowerCase().replaceAll(" ", "_"))
          .toSet()
          .toList();
      userData["motivation"] = motivation;
      print("Updated Motivation: ${userData["motivation"]}");
    }

    await prefs.setBool("ai_onboarding_done", true);
    print("AI onboarding completed and locked.");
  }

  Future<void> _runSteps() async {
    await _processCustomInputs();

    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _steps[i].done = true);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    await StorageService.saveUserData(userData);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                width: 220,
                child: Lottie.asset(
                  'assets/animations/blue_loading.json',
                  repeat: true,
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Preparing your personal\nworkout plan…',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ...List.generate(_steps.length, (i) {
                final step = _steps[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        step.done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: step.done
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        step.label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: step.done
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),

              const LinearProgressIndicator(
                backgroundColor: AppColors.card,
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem {
  final String label;
  bool done = false;
  _StepItem(this.label);
}
