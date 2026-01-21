import 'package:flutter/material.dart';

import '../../../data/store/calculation_store.dart';
import '../../../shared/shared.dart';

// ==================== CORREÇÃO DE SÓDIO ====================
class SodiumCorrectionScreen extends StatefulWidget {
  const SodiumCorrectionScreen({super.key});

  @override
  State<SodiumCorrectionScreen> createState() => _SodiumCorrectionScreenState();
}

class _SodiumCorrectionScreenState extends State<SodiumCorrectionScreen> {
  final _sodiumController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _store = CalculationStore();
  double? _correctedSodium;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('sodium_correction');
    if (values != null) {
      _sodiumController.text = values['sodium'] ?? '';
      _glucoseController.text = values['glucose'] ?? '';
      _correctedSodium = values['correctedSodium'];
    }
  }

  void _calcular() {
    final sodium = double.tryParse(_sodiumController.text.replaceAll(',', '.'));
    final glucose = double.tryParse(_glucoseController.text.replaceAll(',', '.'));
    if (sodium == null || glucose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos'), backgroundColor: Colors.red),
      );
      return;
    }
    final corrected = sodium + 1.6 * ((glucose - 100) / 100);
    final classification = corrected < 135 ? 'Hiponatremia' : (corrected > 145 ? 'Hipernatremia' : 'Normal');
    setState(() => _correctedSodium = corrected);
    _store.setResult('sodium_correction', corrected, classification: classification);
    _store.setFormValues('sodium_correction', {'sodium': _sodiumController.text, 'glucose': _glucoseController.text, 'correctedSodium': _correctedSodium});
  }

  void _limpar() {
    setState(() {
      _sodiumController.clear();
      _glucoseController.clear();
      _correctedSodium = null;
    });
    _store.clearFormValues('sodium_correction');
    _store.clearResult('sodium_correction');
  }

  Color _getColor(double sodium) => sodium < 135 ? Colors.orange : (sodium > 145 ? Colors.red : Colors.green);
  String _getClassification(double sodium) => sodium < 135 ? 'Hiponatremia' : (sodium > 145 ? 'Hipernatremia' : 'Normal');

  @override
  void dispose() {
    _sodiumController.dispose();
    _glucoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Correção de Sódio'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.science_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Sódio Corrigido pela Glicemia', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Na⁺ corr = Na⁺ + 1.6 × ((Glic - 100) / 100)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            AppTextField(controller: _sodiumController, labelText: 'Sódio medido (mEq/L)', hintText: 'Ex: 130', prefixIcon: Icons.water_drop_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            AppTextField(controller: _glucoseController, labelText: 'Glicemia (mg/dL)', hintText: 'Ex: 400', prefixIcon: Icons.bloodtype_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 24),
            CalculateButtons(onCalculate: _calcular, onClear: _limpar),
            if (_correctedSodium != null) ...[
              const SizedBox(height: 32),
              ResultCard(title: 'Sódio Corrigido', value: _correctedSodium!.toStringAsFixed(1), unit: 'mEq/L', classification: _getClassification(_correctedSodium!), color: _getColor(_correctedSodium!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== OSMOLARIDADE PLASMÁTICA ====================
class OsmolarityScreen extends StatefulWidget {
  const OsmolarityScreen({super.key});

  @override
  State<OsmolarityScreen> createState() => _OsmolarityScreenState();
}

class _OsmolarityScreenState extends State<OsmolarityScreen> {
  final _sodiumController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _ureaController = TextEditingController();
  final _store = CalculationStore();
  double? _osmolarity;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('osmolarity');
    if (values != null) {
      _sodiumController.text = values['sodium'] ?? '';
      _glucoseController.text = values['glucose'] ?? '';
      _ureaController.text = values['urea'] ?? '';
      _osmolarity = values['osmolarity'];
    }
  }

  void _calcular() {
    final sodium = double.tryParse(_sodiumController.text.replaceAll(',', '.'));
    final glucose = double.tryParse(_glucoseController.text.replaceAll(',', '.'));
    final urea = double.tryParse(_ureaController.text.replaceAll(',', '.'));
    if (sodium == null || glucose == null || urea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos'), backgroundColor: Colors.red),
      );
      return;
    }
    final osm = (2 * sodium) + (glucose / 18) + (urea / 6);
    final classification = osm < 280 ? 'Hipo-osmolar' : (osm > 295 ? 'Hiperosmolar' : 'Normal');
    setState(() => _osmolarity = osm);
    _store.setResult('osmolarity', osm, classification: classification);
    _store.setFormValues('osmolarity', {'sodium': _sodiumController.text, 'glucose': _glucoseController.text, 'urea': _ureaController.text, 'osmolarity': _osmolarity});
  }

  void _limpar() {
    setState(() {
      _sodiumController.clear();
      _glucoseController.clear();
      _ureaController.clear();
      _osmolarity = null;
    });
    _store.clearFormValues('osmolarity');
    _store.clearResult('osmolarity');
  }

  Color _getColor(double osm) => osm < 280 ? Colors.orange : (osm > 295 ? Colors.red : Colors.green);
  String _getClassification(double osm) => osm < 280 ? 'Hipo-osmolar' : (osm > 295 ? 'Hiperosmolar' : 'Normal');

  @override
  void dispose() {
    _sodiumController.dispose();
    _glucoseController.dispose();
    _ureaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Osmolaridade Plasmática'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.opacity_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Osmolaridade Calculada', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Osm = 2×Na + (Glic/18) + (Ureia/6)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            AppTextField(controller: _sodiumController, labelText: 'Sódio (mEq/L)', hintText: 'Ex: 140', prefixIcon: Icons.water_drop_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            AppTextField(controller: _glucoseController, labelText: 'Glicemia (mg/dL)', hintText: 'Ex: 100', prefixIcon: Icons.bloodtype_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            AppTextField(controller: _ureaController, labelText: 'Ureia (mg/dL)', hintText: 'Ex: 40', prefixIcon: Icons.science_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 24),
            CalculateButtons(onCalculate: _calcular, onClear: _limpar),
            if (_osmolarity != null) ...[
              const SizedBox(height: 32),
              ResultCard(title: 'Osmolaridade', value: _osmolarity!.toStringAsFixed(1), unit: 'mOsm/L', classification: _getClassification(_osmolarity!), color: _getColor(_osmolarity!)),
              const SizedBox(height: 8),
              Text('Normal: 280-295 mOsm/L', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== IDADE GESTACIONAL / DPP ====================
class GestationalAgeScreen extends StatefulWidget {
  const GestationalAgeScreen({super.key});

  @override
  State<GestationalAgeScreen> createState() => _GestationalAgeScreenState();
}

class _GestationalAgeScreenState extends State<GestationalAgeScreen> {
  final _store = CalculationStore();
  DateTime? _dum;
  int? _semanas;
  int? _dias;
  DateTime? _dpp;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('gestational_age');
    if (values != null && values['dum'] != null) {
      _calcular(DateTime.parse(values['dum']));
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dum ?? DateTime.now().subtract(const Duration(days: 60)),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
      helpText: 'Selecione a DUM',
    );
    if (picked != null) _calcular(picked);
  }

  void _calcular(DateTime dum) {
    final diff = DateTime.now().difference(dum).inDays;
    setState(() {
      _dum = dum;
      _semanas = diff ~/ 7;
      _dias = diff % 7;
      _dpp = dum.add(const Duration(days: 280));
    });
    _store.setResult('gestational_age', _semanas!.toDouble(), classification: 'Idade Gestacional');
    _store.setFormValues('gestational_age', {'dum': _dum?.toIso8601String()});
  }

  void _limpar() {
    setState(() {
      _dum = null;
      _semanas = null;
      _dias = null;
      _dpp = null;
    });
    _store.clearFormValues('gestational_age');
    _store.clearResult('gestational_age');
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String _getTrimestre(int semanas) => semanas < 14 ? '1º Trimestre' : (semanas < 28 ? '2º Trimestre' : '3º Trimestre');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Idade Gestacional'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.pregnant_woman_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Calculadora Obstétrica', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_dum != null ? 'DUM: ${_formatDate(_dum!)}' : 'Selecionar DUM'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            if (_dum != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
            ],
            if (_semanas != null && _dpp != null) ...[
              const SizedBox(height: 32),
              _buildIGCard(context),
              const SizedBox(height: 16),
              _buildDPPCard(context),
              const SizedBox(height: 24),
              _buildInfoTable(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIGCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        children: [
          Text('Idade Gestacional', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('$_semanas sem + $_dias dias', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(_getTrimestre(_semanas!), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDPPCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink, width: 2),
      ),
      child: Column(
        children: [
          Text('Data Provável do Parto', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(_formatDate(_dpp!), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.pink)),
          const SizedBox(height: 8),
          Text('(40 semanas)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
            child: Text('Informações', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          _buildInfoRow(context, 'DUM', _formatDate(_dum!)),
          _buildInfoRow(context, 'Dias de gestação', '${_semanas! * 7 + _dias!} dias'),
          _buildInfoRow(context, 'Semanas completas', '$_semanas semanas'),
          _buildInfoRow(context, 'Trimestre', _getTrimestre(_semanas!), isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
