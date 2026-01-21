import 'package:flutter/material.dart';

import '../../data/store/calculation_store.dart';
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
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildDrugList(),
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
