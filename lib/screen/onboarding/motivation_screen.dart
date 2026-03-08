import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/onboarding_layout.dart';
import '../../widgets/selection_card.dart';
import 'ai_setup_screen.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final List<String> _selected = [];
  final TextEditingController _customController = TextEditingController();

  static const List<String> _motivations = [
    'Lose weight',
    "Look better and attractive",
    'Build muscle',
    'Reduce stress',
    'Stay active',
    'Improve mental health',
    'Build habit',
  ];

  void _toggle(String m) {
    setState(() {
      _selected.contains(m) ? _selected.remove(m) : _selected.add(m);
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
      title: 'Primary Motivation',
      subtitle: 'What drives you to work out? Pick all that apply.',
      canContinue: _selected.isNotEmpty ||
          _customController.text.trim().isNotEmpty,
      onContinue: () {
        userData['motivation'] = List<String>.from(_selected);
        final customText = _customController.text.trim();
        if (customText.isNotEmpty) {
          userData['custom_motivation'] = customText;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiSetupScreen()),
        );
      },
      child: ListView(
        children: [
          ..._motivations.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectionCard(
                  label: m,
                  isSelected: _selected.contains(m),
                  onTap: () => _toggle(m),
                ),
              )),

          const SizedBox(height: 20),
          Text(
            'Anything else you want to achieve?',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'E.g. train for a marathon, improve flexibility…',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
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