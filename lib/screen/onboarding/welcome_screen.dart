import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'goal_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 32),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Your '),
                    TextSpan(
                      text: 'AI',
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(text: ' Fitness Mentor'),
                  ],
                ),
                style: textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              Text(
                'Get personalised 5–7 minute workouts\ndesigned for busy people like you.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoalScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
