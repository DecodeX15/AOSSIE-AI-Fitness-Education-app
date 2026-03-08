import 'package:flutter/material.dart';
import '../data/user_data.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(userData);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Plan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Text('Welcome back!', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Here\'s a summary of your profile.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ..._buildInfoCards(textTheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoCards(TextTheme textTheme) {
    final entries = <MapEntry<String, String>>[
      MapEntry('Goals', _listToString(userData['goals'])),
      MapEntry('Injury', _listToString(userData['injury'])),
      MapEntry('Level', userData['level']?.toString() ?? '–'),
      MapEntry('Time', userData['time']?.toString() ?? '–'),
      MapEntry('Motivation', _listToString(userData['motivation'])),
    ];

    return entries.map((e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                e.key,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: Text(e.value, style: textTheme.bodyMedium),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _listToString(dynamic value) {
    if (value is List) return value.join(', ');
    return value?.toString() ?? '–';
  }
}