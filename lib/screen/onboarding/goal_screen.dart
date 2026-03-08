import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/onboarding_layout.dart';
import '../../widgets/selection_card.dart';
import 'injury_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final List<String> _selected = [];
  final TextEditingController _customController = TextEditingController();

  static const List<String> _goals = [
    'Fat Burn',
    'Strength',
    'Mobility',
    'General Fitness',
    'Stress Relief',
    'Cardio Fitness',
    'Improve Stamina',
    'Better Posture',
  ];

  void _toggle(String goal) {
    setState(() {
      _selected.contains(goal)
          ? _selected.remove(goal)
          : _selected.add(goal);
    });
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: 'Choose Your Goals',
      subtitle: 'Select one or more goals that match your needs.',
      canContinue: _selected.isNotEmpty,
      onContinue: () {
        final goals = List<String>.from(_selected);
        final custom = _customController.text.trim();
        if (custom.isNotEmpty) goals.add(custom);
        userData['goals'] = goals;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InjuryScreen()),
        );
      },
      child: ListView(
        children: [
          ...List.generate(_goals.length, (i) {
            final goal = _goals[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _goals.length - 1 ? 12 : 0),
              child: SelectionCard(
                label: goal,
                isSelected: _selected.contains(goal),
                onTap: () => _toggle(goal),
              ),
            );
          }),

          const SizedBox(height: 20),
          Text(
            'Anything else you want to achieve?',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customController,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'E.g. train for a marathon, improve flexibility…',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
