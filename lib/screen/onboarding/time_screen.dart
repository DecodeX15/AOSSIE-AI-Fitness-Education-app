import 'package:flutter/material.dart';
import '../../data/user_data.dart';
import '../../widgets/onboarding_layout.dart';
import '../../widgets/selection_card.dart';
import 'motivation_screen.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  List<String> _selectedTimes = [];

  static const List<String> _times = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: 'When Do You Usually Train?',
      subtitle: 'Pick the duration that fits your schedule.',
      canContinue: _selectedTimes.isNotEmpty,
      onContinue: () {
        userData['time'] = _selectedTimes;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MotivationScreen()),
        );
      },
      child: ListView.separated(
        itemCount: _times.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final time = _times[i];
          return SelectionCard(
            label: time,
            isSelected: _selectedTimes.contains(time),
            onTap: () => setState(() {
              if (_selectedTimes.contains(time)) {
                _selectedTimes.remove(time);
              } else {
                _selectedTimes.add(time);
              }
            }),
          );
        },
      ),
    );
  }
}
