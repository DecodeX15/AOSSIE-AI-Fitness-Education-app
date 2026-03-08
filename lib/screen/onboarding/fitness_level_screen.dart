import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../widgets/onboarding_layout.dart';
import '../../widgets/selection_card.dart';
import 'time_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  String _level = '';

  static const List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Athlete',
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: 'Choose Your Fitness Level',
      subtitle: 'This helps us tailor the intensity for you.',
      canContinue: _level.isNotEmpty,
      onContinue: () {
        userData['level'] = _level;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimeScreen()),
        );
      },
      child: ListView.separated(
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final level = _levels[i];
          return SelectionCard(
            label: level,
            isSelected: _level == level,
            onTap: () => setState(() => _level = level),
          );
        },
      ),
    );
  }
}