import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import '../../services/storage_service.dart';
import '../../data/user_data.dart';
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

  Future<void> _runSteps() async {
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
              FadeTransition(
                opacity: _pulseCtrl.drive(Tween(begin: 0.4, end: 1.0)),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 56,
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
