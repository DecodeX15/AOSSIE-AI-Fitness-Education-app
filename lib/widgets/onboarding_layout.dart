import 'package:flutter/material.dart';
class OnboardingLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onContinue;
  final bool canContinue;

  const OnboardingLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.onContinue,
    this.canContinue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 12),
              Expanded(child: child),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: ElevatedButton(
                  onPressed: canContinue ? onContinue : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
