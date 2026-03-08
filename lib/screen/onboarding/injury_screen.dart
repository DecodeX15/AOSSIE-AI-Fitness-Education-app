import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/onboarding_layout.dart';
import '../../widgets/selection_card.dart';
import 'fitness_level_screen.dart';

class InjuryScreen extends StatefulWidget {
  const InjuryScreen({super.key});

  @override
  State<InjuryScreen> createState() => _InjuryScreenState();
}

class _InjuryScreenState extends State<InjuryScreen> {
  final List<String> _selected = [];
  final TextEditingController _customController = TextEditingController();

  static const List<String> _options = [
    'None',
    'Back pain',
    'Knee pain',
    'Shoulder pain',
    'Wrist / Hip pain',
    'Poor cardiovascular endurance',
    'Neck / shoulder stiffness',
    'Shortness of breath during activities',
    'Ankle pain and stiffness',
  ];

  void _toggle(String option) {
    setState(() {
      if (option == 'None') {
        _selected.clear();
        _selected.add('None');
      } else {
        _selected.remove('None');
        _selected.contains(option)
            ? _selected.remove(option)
            : _selected.add(option);
      }
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
      title: 'Health Issues',
      subtitle: 'Select all that apply so we can keep your workouts safe.',
      canContinue: _selected.isNotEmpty,
      onContinue: () {
        final injuries = List<String>.from(_selected);
        final custom = _customController.text.trim();
        if (custom.isNotEmpty) injuries.add(custom);
        userData['injury'] = injuries;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FitnessLevelScreen()),
        );
      },
      child: ListView(
        children: [
          ...List.generate(_options.length, (i) {
            final option = _options[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < _options.length - 1 ? 12 : 0,
              ),
              child: SelectionCard(
                label: option,
                isSelected: _selected.contains(option),
                onTap: () => _toggle(option),
              ),
            );
          }),

          const SizedBox(height: 20),
          Text(
            'Anything else we should know?',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customController,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'E.g. recent surgery, chronic fatigue…',
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
