import 'package:flutter/material.dart';
import '../../data/user_data.dart';
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
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: 'Primary Motivation',
      subtitle: 'What drives you to work out? Pick all that apply.',
      canContinue: _selected.isNotEmpty,
      onContinue: () {
        userData['motivation'] = List<String>.from(_selected);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiSetupScreen()),
        );
      },
      child: ListView.separated(
        itemCount: _motivations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final m = _motivations[i];
          return SelectionCard(
            label: m,
            isSelected: _selected.contains(m),
            onTap: () => _toggle(m),
          );
        },
      ),
    );
  }
}