import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../../data/store/calculation_store.dart';
import '../../../shared/shared.dart';
import '../data/intubation_drugs.dart';
import '../widgets/intubation_drug_card.dart';
import '../../pediatria/widgets/weight_selector.dart';

/// Screen displaying intubation drug dosages with weight-based calculations
class IntubationScreen extends StatefulWidget {
  const IntubationScreen({super.key});

  @override
  State<IntubationScreen> createState() => _IntubationScreenState();
}

class _IntubationScreenState extends State<IntubationScreen> {
  static const double _defaultWeight = 70.0;
  static const double _minWeight = 1.0;
  static const double _maxWeight = 200.0;

  double _peso = _defaultWeight;
  final CalculationStore _store = CalculationStore();

  @override
  void initState() {
    super.initState();
    _loadSharedWeight();
  }

  void _loadSharedWeight() {
    if (_store.sharedPeso.isNotEmpty) {
      final parsedPeso = double.tryParse(_store.sharedPeso.replaceAll(',', '.'));
      if (parsedPeso != null &&
          parsedPeso >= _minWeight &&
          parsedPeso <= _maxWeight) {
        _peso = parsedPeso;
      }
    }
  }

  void _onPesoChanged(double value) {
    setState(() {
      _peso = value;
    });
    _store.setSharedPeso(value.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intubação'),
        centerTitle: true,
      ),
      body: ResponsiveContent(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildDrugList(),
            ),
          ],
        ),
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
            'Medicações para Intubação',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Doses baseadas no peso do paciente',
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
