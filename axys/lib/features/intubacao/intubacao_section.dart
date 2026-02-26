import 'package:flutter/material.dart';

import '../../shared/shared.dart';
import '../calculos/data/intubation_drugs.dart';
import '../calculos/widgets/intubation_drug_card.dart';
import '../pediatria/widgets/weight_selector.dart';

/// Section displaying intubation drug dosages with weight-based calculations
class IntubacaoSection extends StatefulWidget {
  const IntubacaoSection({super.key});

  @override
  State<IntubacaoSection> createState() => _IntubacaoSectionState();
}

class _IntubacaoSectionState extends State<IntubacaoSection> {
  static const double _defaultWeight = 70.0;
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
            'Intubação',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Medicações para Intubação - Doses baseadas no peso do paciente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (int catIndex = 0; catIndex < IntubationDrugs.categories.length; catIndex++)
          ..._buildCategorySection(context, IntubationDrugs.categories[catIndex], catIndex),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildCategorySection(
    BuildContext context,
    IntubationDrugCategory category,
    int categoryIndex,
  ) {
    return [
      if (categoryIndex > 0) const SizedBox(height: 24),
      _buildCategoryHeader(context, category.name),
      const SizedBox(height: 12),
      for (final drug in category.drugs)
        IntubationDrugCard(
          drug: drug,
          peso: _peso,
        ),
    ];
  }

  Widget _buildCategoryHeader(BuildContext context, String categoryName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            categoryName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
