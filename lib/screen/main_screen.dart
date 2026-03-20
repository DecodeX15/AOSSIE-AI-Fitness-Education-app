import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainexerciseScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  const MainexerciseScreen({super.key, required this.exercises});

  @override
  State<MainexerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<MainexerciseScreen> {
  final FlutterTts tts = FlutterTts();
  VideoPlayerController? videoController;

  int currentIndex = 0;
  int currentInstruction = 0;
  bool isResting = false;
  bool isPreparing = true;
  int timerSeconds = 10;

  @override
  void initState() {
    super.initState();
    _initTts().then((_) => _initVideo().then((_) => _startFlow(isFirst: true)));
  }

  Map<String, dynamic> get currentExercise => widget.exercises[currentIndex];

  Map<String, dynamic>? get nextExercise =>
      currentIndex + 1 < widget.exercises.length
      ? widget.exercises[currentIndex + 1]
      : null;
  Map<String, dynamic> get displayExercise =>
      isResting && nextExercise != null ? nextExercise! : currentExercise;

  Future<void> _initTts() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.awaitSpeakCompletion(true);
  }

  Future<void> _initVideo({Map<String, dynamic>? exercise}) async {
    final ex = exercise ?? currentExercise;
    videoController?.dispose();
    videoController = null;

    final isLottie = ex["is_lottie"] as bool? ?? false;
    if (!isLottie) {
      videoController = VideoPlayerController.networkUrl(
        Uri.parse(ex["animation_link"]),
      );
      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();
      if (mounted) setState(() {});
    }
  }

  Future<void> _startFlow({bool isFirst = false}) async {
    if (isFirst) {
      setState(() {
        isPreparing = true;
        timerSeconds = 5;
      });
      await tts.speak("Get ready for ${currentExercise["name"]}");
      await _countdown(5);
      if (!mounted) return;
    }
    setState(() {
      isPreparing = false;
      isResting = false;
      timerSeconds = 90;
      currentInstruction = 0;
    });
    await tts.speak("Start!");
    _speakInstructions(90);
    await _countdown(90);
    if (!mounted) return;

    if (nextExercise == null) {
      _showSessionComplete();
      return;
    }
    setState(() {
      isResting = true;
      timerSeconds = 10;
    });
    await _initVideo(exercise: nextExercise);
    await tts.speak("Good job! Rest. Next up: ${nextExercise!["name"]}");
    await _countdown(10);
    if (!mounted) return;

    setState(() {
      currentIndex++;
      isResting = false;
      currentInstruction = 0;
    });
    await _initVideo();
    _startFlow();
  }

  Future<void> _speakInstructions(int exerciseDuration) async {
    final instructions = (currentExercise["instructions"] as String)
        .split(". ")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (instructions.isEmpty) return;
    int gap = (exerciseDuration ~/ instructions.length);
    for (int i = 0; i < instructions.length; i++) {
      if (!mounted || isResting) break;
      setState(() => currentInstruction = i);
      await tts.speak(instructions[i]);
      await Future.delayed(Duration(seconds: gap));
    }
  }

  Future<void> _countdown(int seconds) async {
    for (int i = seconds; i > 0; i--) {
      if (!mounted) break;
      setState(() => timerSeconds = i);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _showSessionComplete() async {
    await _savedata();
    tts.speak("Session complete! Great work!");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          "Session Complete!",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "How was the session?",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _feedbackBtn("Too Hard", "beginner", "low"),
                _feedbackBtn("Just Right", null, null),
                _feedbackBtn("Too Easy", "advanced", "high"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackBtn(String label, String? difficulty, String? intensity) {
    return GestureDetector(
      onTap: () async {
        if (difficulty != null && intensity != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("level", difficulty);
          await prefs.setString("intensity", intensity);
          print("Updated → difficulty: $difficulty, intensity: $intensity");
        }
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSelected,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _savedata() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList("last_7_days_exercises") ?? [];
    final exerciseSet = Set<String>.from(existing);
    for (var ex in widget.exercises) {
      exerciseSet.add(ex["exercise_id"]);
    }
    await prefs.setStringList("last_7_days_exercises", exerciseSet.toList());
    await prefs.setInt(
      "last_session_time",
      DateTime.now().millisecondsSinceEpoch,
    );
    print("Saved: $exerciseSet");
  }

  @override
  void dispose() {
    videoController?.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final exercise = currentExercise;
    final display = displayExercise;
    final isLottie = display["is_lottie"] as bool? ?? false;

    final instructions = (exercise["instructions"] as String)
        .split(". ")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String timerLabel;
    Color timerColor;
    if (isPreparing) {
      timerLabel = "Get Ready: ${timerSeconds}s";
      timerColor = AppColors.primaryLight;
    } else if (isResting) {
      timerLabel = "Rest: ${timerSeconds}s";
      timerColor = AppColors.primaryLight;
    } else {
      timerLabel = "${timerSeconds}s";
      timerColor = AppColors.primary;
    }

    String infoText;
    if (isPreparing) {
      infoText = exercise["overview"];
    } else if (isResting) {
      infoText = "Next: ${nextExercise?["name"] ?? ""}";
    } else {
      infoText = instructions.isNotEmpty
          ? instructions[currentInstruction.clamp(0, instructions.length - 1)]
          : "";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "${currentIndex + 1}/${widget.exercises.length} • ${exercise["name"]}",
          style: textTheme.titleMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isResting
                        ? AppColors.borderSelected
                        : AppColors.border,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isLottie
                      ? Lottie.asset(
                          'assets/animations/${display["exercise_id"]}.json',
                          repeat: true,
                        )
                      : (videoController != null &&
                            videoController!.value.isInitialized)
                      ? VideoPlayer(videoController!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  timerLabel,
                  style: textTheme.headlineLarge?.copyWith(
                    color: timerColor,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  infoText,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
