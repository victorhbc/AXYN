import 'package:flutter/material.dart';

import '../../shared/shared.dart';
import 'data/pediatric_drugs.dart';
import 'widgets/drug_dosage_card.dart';
import 'widgets/weight_selector.dart';

/// Section displaying pediatric drug dosages with weight-based calculations
class PediatriaSection extends StatefulWidget {
  const PediatriaSection({super.key});

  @override
  State<PediatriaSection> createState() => _PediatriaSectionState();
}

class _PediatriaSectionState extends State<PediatriaSection> {
  static const double _defaultWeight = 10.0;
  static const double _minWeight = 1.0;
  static const double _maxWeight = 200.0;

  double _peso = _defaultWeight;
  bool _showWeightReminder = true;

  @override
  void initState() {
    super.initState();
    // Reset reminder every time section is shown
    _showWeightReminder = true;
  }

  void _onPesoChanged(double value) {
    setState(() {
      _peso = value;
    });
  }

  void _dismissReminder() {
    setState(() {
      _showWeightReminder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveContent(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showWeightReminder) _buildWeightReminder(context),
            _buildHeader(context),
            Expanded(
              child: _buildDrugList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightReminder(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lembre-se de atualizar o peso do paciente nesta seção',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _dismissReminder,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pediatria',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          WeightSelector(
            peso: _peso,
            onChanged: _onPesoChanged,
            min: _minWeight,
            max: _maxWeight,
          ),
        ],
      ),
    );
  }

  Widget _buildDrugList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: PediatricDrugs.all.length + 1, // +1 for bottom padding
      itemBuilder: (context, index) {
        if (index == PediatricDrugs.all.length) {
          return const SizedBox(height: 16);
        }
        return DrugDosageCard(
          drug: PediatricDrugs.all[index],
          peso: _peso,
        );
      },
    );
  }
}
