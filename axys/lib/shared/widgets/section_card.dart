import 'package:flutter/material.dart';

/// Reusable section card with title and options
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Radio option for score calculators
class ScoreRadioOption<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final int points;

  const ScoreRadioOption({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      secondary: Text(
        '$points',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      dense: true,
    );
  }
}

/// Checkbox option for score calculators
class ScoreCheckboxOption extends StatelessWidget {
  final String label;
  final String points;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const ScoreCheckboxOption({
    super.key,
    required this.label,
    required this.points,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      secondary: Text(
        points,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
