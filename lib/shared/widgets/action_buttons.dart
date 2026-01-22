import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Dismisses the keyboard by unfocusing the current focus node
void _dismissKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

/// Reusable action buttons row (Calculate + Clear)
class CalculateButtons extends StatelessWidget {
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  final String calculateLabel;
  final String clearLabel;

  const CalculateButtons({
    super.key,
    required this.onCalculate,
    required this.onClear,
    this.calculateLabel = AppStrings.calcular,
    this.clearLabel = AppStrings.limpar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              _dismissKeyboard(context);
              onCalculate();
            },
            icon: const Icon(Icons.calculate),
            label: Text(calculateLabel),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            _dismissKeyboard(context);
            onClear();
          },
          icon: const Icon(Icons.refresh),
          label: Text(clearLabel),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable save/clear buttons row for score calculators
class SaveClearButtons extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback onClear;
  final String saveLabel;
  final String clearLabel;

  const SaveClearButtons({
    super.key,
    required this.onSave,
    required this.onClear,
    this.saveLabel = AppStrings.salvar,
    this.clearLabel = AppStrings.limpar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onSave != null
                ? () {
                    _dismissKeyboard(context);
                    onSave!();
                  }
                : null,
            icon: const Icon(Icons.save),
            label: Text(saveLabel),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            _dismissKeyboard(context);
            onClear();
          },
          icon: const Icon(Icons.refresh),
          label: Text(clearLabel),
        ),
      ],
    );
  }
}
