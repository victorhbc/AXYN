import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/store/calculation_store.dart';
import '../../../shared/shared.dart';

class CreatinineClearanceScreen extends StatefulWidget {
  const CreatinineClearanceScreen({super.key});

  @override
  State<CreatinineClearanceScreen> createState() => _CreatinineClearanceScreenState();
}

class _CreatinineClearanceScreenState extends State<CreatinineClearanceScreen> {
  final _idadeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _creatininaController = TextEditingController();
  final _store = CalculationStore();
  bool _isFemale = false;
  double? _clearance;
  String _classificacao = '';
  Color _classificacaoColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadFormValues();
  }

  void _loadFormValues() {
    if (_store.sharedIdade.isNotEmpty) _idadeController.text = _store.sharedIdade;
    if (_store.sharedPeso.isNotEmpty) _pesoController.text = _store.sharedPeso;
    
    final values = _store.getFormValues('creatinine_clearance');
    if (values != null) {
      if (values['idade']?.isNotEmpty == true) _idadeController.text = values['idade'];
      if (values['peso']?.isNotEmpty == true) _pesoController.text = values['peso'];
      _creatininaController.text = values['creatinina'] ?? '';
      _isFemale = values['isFemale'] ?? false;
      if (values['clearance'] != null) {
        _clearance = values['clearance'];
        _classificacao = values['classificacao'] ?? '';
        _classificacaoColor = _getClassificacaoColor(_clearance!);
      }
    }
  }

  void _saveFormValues() {
    _store.setSharedIdade(_idadeController.text);
    _store.setSharedPeso(_pesoController.text);
    _store.setFormValues('creatinine_clearance', {
      'idade': _idadeController.text,
      'peso': _pesoController.text,
      'creatinina': _creatininaController.text,
      'isFemale': _isFemale,
      'clearance': _clearance,
      'classificacao': _classificacao,
    });
  }

  void _calcularClearance() {
    final idade = int.tryParse(_idadeController.text);
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final creatinina = double.tryParse(_creatininaController.text.replaceAll(',', '.'));

    if (idade == null || peso == null || creatinina == null || creatinina == 0) {
      _showError(AppStrings.valoresInvalidos);
      return;
    }

    double clearance = ((140 - idade) * peso) / (72 * creatinina);
    if (_isFemale) clearance *= 0.85;

    final classificacao = _getClassificacao(clearance);

    setState(() {
      _clearance = clearance;
      _classificacao = classificacao;
      _classificacaoColor = _getClassificacaoColor(clearance);
    });

    _store.setResult('creatinine_clearance', clearance, classification: classificacao);
    _saveFormValues();
  }

  String _getClassificacao(double clearance) {
    if (clearance >= 90) return 'Normal (G1)';
    if (clearance >= 60) return 'Levemente diminuída (G2)';
    if (clearance >= 45) return 'Leve a moderada (G3a)';
    if (clearance >= 30) return 'Moderada a severa (G3b)';
    if (clearance >= 15) return 'Severamente diminuída (G4)';
    return 'Falência Renal (G5)';
  }

  Color _getClassificacaoColor(double clearance) {
    if (clearance >= 90) return Colors.green;
    if (clearance >= 60) return Colors.lightGreen;
    if (clearance >= 45) return Colors.orange;
    if (clearance >= 30) return Colors.deepOrange;
    if (clearance >= 15) return Colors.red;
    return Colors.red.shade900;
  }

  void _limpar() {
    setState(() {
      _idadeController.clear();
      _pesoController.clear();
      _creatininaController.clear();
      _isFemale = false;
      _clearance = null;
      _classificacao = '';
    });
    _store.clearFormValues('creatinine_clearance');
    _store.clearResult('creatinine_clearance');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _idadeController.dispose();
    _pesoController.dispose();
    _creatininaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clearance de Creatinina'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Fórmula de Cockcroft-Gault',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Estimativa da Taxa de Filtração Glomerular',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _idadeController,
              labelText: AppStrings.idadeAnos,
              hintText: 'Ex: 45',
              prefixIcon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _pesoController,
              labelText: AppStrings.pesoKg,
              hintText: 'Ex: 70',
              prefixIcon: Icons.fitness_center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _creatininaController,
              labelText: 'Creatinina Sérica (mg/dL)',
              hintText: 'Ex: 1.2',
              prefixIcon: Icons.science_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildSexSelector(),
            const SizedBox(height: 24),
            CalculateButtons(onCalculate: _calcularClearance, onClear: _limpar),
            if (_clearance != null) ...[
              const SizedBox(height: 32),
              ResultCard(
                title: 'Clearance de Creatinina',
                value: _clearance!.toStringAsFixed(1),
                unit: 'mL/min',
                classification: _classificacao,
                color: _classificacaoColor,
              ),
              const SizedBox(height: 24),
              _buildClearanceTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSexSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wc_outlined),
          const SizedBox(width: 16),
          const Text('Sexo:'),
          const SizedBox(width: 16),
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Masculino'), icon: Icon(Icons.male)),
                ButtonSegment(value: true, label: Text('Feminino'), icon: Icon(Icons.female)),
              ],
              selected: {_isFemale},
              onSelectionChanged: (selection) => setState(() => _isFemale = selection.first),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearanceTable() {
    return ClassificationTable(
      title: 'Classificação - Doença Renal Crônica',
      rows: [
        const TableRowData(value: '≥ 90 mL/min', label: 'Normal (G1)', color: Colors.green),
        const TableRowData(value: '60-89 mL/min', label: 'Levemente diminuída (G2)', color: Colors.lightGreen),
        const TableRowData(value: '45-59 mL/min', label: 'Leve a moderada (G3a)', color: Colors.orange),
        const TableRowData(value: '30-44 mL/min', label: 'Moderada a severa (G3b)', color: Colors.deepOrange),
        const TableRowData(value: '15-29 mL/min', label: 'Severamente diminuída (G4)', color: Colors.red),
        TableRowData(value: '< 15 mL/min', label: 'Falência Renal (G5)', color: Colors.red.shade900),
      ],
    );
  }
}
