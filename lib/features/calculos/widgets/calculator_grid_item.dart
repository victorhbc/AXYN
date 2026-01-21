import 'package:flutter/material.dart';

import '../../../core/theme/classification_colors.dart';

/// Grid item widget for displaying calculator cards
class CalculatorGridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final double? result;
  final String? resultUnit;
  final String? classification;
  final bool hasResult;
  final VoidCallback? onClear;

  const CalculatorGridItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.result,
    this.resultUnit,
    this.classification,
    this.hasResult = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final classificationColor = ClassificationColors.getColor(classification);

    return Material(
      color: hasResult
          ? classificationColor.withOpacity(0.15)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: hasResult
                ? Border.all(
                    color: classificationColor.withOpacity(0.5),
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Center(
                child: hasResult && result != null
                    ? _buildResultContent(context, classificationColor)
                    : _buildDefaultContent(context),
              ),
              if (hasResult && onClear != null)
                _buildClearButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          result!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          classification ?? '',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Positioned(
      top: -8,
      right: -8,
      child: IconButton(
        icon: Icon(
          Icons.close,
          size: 18,
          color: Colors.grey.shade600,
        ),
        onPressed: onClear,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.all(4),
          minimumSize: const Size(28, 28),
        ),
      ),
    );
  }
}
