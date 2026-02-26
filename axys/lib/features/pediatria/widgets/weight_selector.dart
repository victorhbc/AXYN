import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for selecting patient weight with a slider
class WeightSelector extends StatelessWidget {
  final double peso;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const WeightSelector({
    super.key,
    required this.peso,
    required this.onChanged,
    this.min = 1,
    this.max = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          _buildSlider(context),
          _buildRangeLabels(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Peso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showWeightInputDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${peso.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showWeightInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: peso.toStringAsFixed(1),
    );
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              // Allow empty string
              if (text.isEmpty) return newValue;
              // Only allow digits and one decimal point
              if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
                return oldValue;
              }
              // Ensure only one decimal point
              if (text.split('.').length > 2) {
                return oldValue;
              }
              // Limit to one decimal place
              if (text.contains('.')) {
                final parts = text.split('.');
                if (parts.length == 2 && parts[1].length > 1) {
                  return oldValue;
                }
              }
              return newValue;
            }),
          ],
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Peso (kg)',
            hintText: 'Ex: 70.5',
            suffixText: 'kg',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final parsed = double.tryParse(value.replaceAll(',', '.'));
            if (parsed != null && parsed >= min && parsed <= max) {
              Navigator.of(context).pop(parsed);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Por favor, insira um valor entre ${min.toStringAsFixed(1)} e ${max.toStringAsFixed(1)} kg'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.replaceAll(',', '.');
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= min && parsed <= max) {
                Navigator.of(context).pop(parsed);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, insira um valor entre ${min.toStringAsFixed(1)} e ${max.toStringAsFixed(1)} kg'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  Widget _buildSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
        thumbColor: Theme.of(context).colorScheme.primary,
        overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
      child: Slider(
        value: peso,
        min: min,
        max: max,
        divisions: ((max - min) * 2).toInt(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRangeLabels(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${min.toInt()} kg',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          '${max.toInt()} kg',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
