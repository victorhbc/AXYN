import 'package:flutter/material.dart';

import '../../../data/store/calculation_store.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/responsive_layout.dart';

// ==================== DOSE POR PESO ====================
class DosePorPesoScreen extends StatefulWidget {
  const DosePorPesoScreen({super.key});

  @override
  State<DosePorPesoScreen> createState() => _DosePorPesoScreenState();
}

class _DosePorPesoScreenState extends State<DosePorPesoScreen> {
  final _pesoController = TextEditingController();
  final _doseController = TextEditingController();
  final _store = CalculationStore();
  double? _resultado;

  @override
  void initState() {
    super.initState();
    if (_store.sharedPeso.isNotEmpty) _pesoController.text = _store.sharedPeso;
    final values = _store.getFormValues('dose_peso');
    if (values != null) {
      if (values['peso']?.isNotEmpty == true) _pesoController.text = values['peso'];
      _doseController.text = values['dose'] ?? '';
      _resultado = values['resultado'];
    }
  }

  void _calcular() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final doseMgKg = double.tryParse(_doseController.text.replaceAll(',', '.'));
    if (peso == null || doseMgKg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira valores válidos'), backgroundColor: Colors.red),
      );
      return;
    }
    final resultado = peso * doseMgKg;
    setState(() => _resultado = resultado);
    _store.setResult('dose_peso', resultado, classification: 'Calculado');
    _store.setSharedPeso(_pesoController.text);
    _store.setFormValues('dose_peso', {'peso': _pesoController.text, 'dose': _doseController.text, 'resultado': _resultado});
  }

  void _limpar() {
    setState(() {
      _pesoController.clear();
      _doseController.clear();
      _resultado = null;
    });
    _store.clearFormValues('dose_peso');
    _store.clearResult('dose_peso');
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dose por Peso'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.medication_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('Cálculo de Dose', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              AppTextField(controller: _pesoController, labelText: 'Peso (kg)', hintText: 'Ex: 70', prefixIcon: Icons.fitness_center, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              AppTextField(controller: _doseController, labelText: 'Dose (mg/kg)', hintText: 'Ex: 10', prefixIcon: Icons.science_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 24),
              CalculateButtons(onCalculate: _calcular, onClear: _limpar),
              if (_resultado != null) ...[
                const SizedBox(height: 32),
                ResultCard(title: 'Dose Total', value: _resultado!.toStringAsFixed(1), unit: 'mg', color: Colors.blue),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== GLASGOW ====================
class GlasgowScreen extends StatefulWidget {
  const GlasgowScreen({super.key});

  @override
  State<GlasgowScreen> createState() => _GlasgowScreenState();
}

class _GlasgowScreenState extends State<GlasgowScreen> {
  final _store = CalculationStore();
  int _ocular = 0, _verbal = 0, _motor = 0;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('glasgow');
    if (values != null) {
      _ocular = values['ocular'] ?? 0;
      _verbal = values['verbal'] ?? 0;
      _motor = values['motor'] ?? 0;
    }
  }

  int get _total => _ocular + _verbal + _motor;
  String _getClassificacao(int score) => score >= 13 ? 'TCE Leve' : (score >= 9 ? 'TCE Moderado' : 'TCE Grave');
  Color _getColor(int score) => score >= 13 ? Colors.green : (score >= 9 ? Colors.orange : Colors.red);

  void _salvar() {
    if (_total > 0) {
      _store.setResult('glasgow', _total.toDouble(), classification: _getClassificacao(_total));
      _store.setFormValues('glasgow', {'ocular': _ocular, 'verbal': _verbal, 'motor': _motor});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
    }
  }

  void _limpar() {
    setState(() { _ocular = _verbal = _motor = 0; });
    _store.clearFormValues('glasgow');
    _store.clearResult('glasgow');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escala de Glasgow'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_total > 0) ScoreDisplay(score: '$_total', classification: _getClassificacao(_total), color: _getColor(_total)),
              const SizedBox(height: 24),
              SectionCard(title: 'Abertura Ocular', children: [
                _buildRadio('Espontânea', 4, _ocular, (v) => setState(() => _ocular = v!)),
                _buildRadio('Ao estímulo verbal', 3, _ocular, (v) => setState(() => _ocular = v!)),
                _buildRadio('Ao estímulo doloroso', 2, _ocular, (v) => setState(() => _ocular = v!)),
                _buildRadio('Ausente', 1, _ocular, (v) => setState(() => _ocular = v!)),
              ]),
              const SizedBox(height: 16),
              SectionCard(title: 'Resposta Verbal', children: [
                _buildRadio('Orientada', 5, _verbal, (v) => setState(() => _verbal = v!)),
                _buildRadio('Confusa', 4, _verbal, (v) => setState(() => _verbal = v!)),
                _buildRadio('Palavras inapropriadas', 3, _verbal, (v) => setState(() => _verbal = v!)),
                _buildRadio('Sons incompreensíveis', 2, _verbal, (v) => setState(() => _verbal = v!)),
                _buildRadio('Ausente', 1, _verbal, (v) => setState(() => _verbal = v!)),
              ]),
              const SizedBox(height: 16),
              SectionCard(title: 'Resposta Motora', children: [
                _buildRadio('Obedece comandos', 6, _motor, (v) => setState(() => _motor = v!)),
                _buildRadio('Localiza dor', 5, _motor, (v) => setState(() => _motor = v!)),
                _buildRadio('Movimento de retirada', 4, _motor, (v) => setState(() => _motor = v!)),
                _buildRadio('Flexão anormal', 3, _motor, (v) => setState(() => _motor = v!)),
                _buildRadio('Extensão anormal', 2, _motor, (v) => setState(() => _motor = v!)),
                _buildRadio('Ausente', 1, _motor, (v) => setState(() => _motor = v!)),
              ]),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _total > 0 ? _salvar : null, onClear: _limpar),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(String label, int value, int groupValue, ValueChanged<int?> onChanged) {
    return RadioListTile<int>(title: Text(label), secondary: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)), value: value, groupValue: groupValue, onChanged: onChanged, dense: true);
  }
}

// ==================== CHA2DS2-VASc ====================
class Cha2ds2VascScreen extends StatefulWidget {
  const Cha2ds2VascScreen({super.key});

  @override
  State<Cha2ds2VascScreen> createState() => _Cha2ds2VascScreenState();
}

class _Cha2ds2VascScreenState extends State<Cha2ds2VascScreen> {
  final _store = CalculationStore();
  bool _chf = false, _hypertension = false, _age75 = false, _diabetes = false;
  bool _stroke = false, _vascular = false, _age65 = false, _female = false;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('cha2ds2vasc');
    if (values != null) {
      _chf = values['chf'] ?? false;
      _hypertension = values['hypertension'] ?? false;
      _age75 = values['age75'] ?? false;
      _diabetes = values['diabetes'] ?? false;
      _stroke = values['stroke'] ?? false;
      _vascular = values['vascular'] ?? false;
      _age65 = values['age65'] ?? false;
      _female = values['female'] ?? false;
    }
  }

  int get _score {
    int s = 0;
    if (_chf) s += 1;
    if (_hypertension) s += 1;
    if (_age75) s += 2;
    if (_diabetes) s += 1;
    if (_stroke) s += 2;
    if (_vascular) s += 1;
    if (_age65) s += 1;
    if (_female) s += 1;
    return s;
  }

  String _getClassificacao(int score) => score == 0 ? 'Baixo risco' : (score == 1 ? 'Risco moderado' : 'Alto risco');
  Color _getColor(int score) => score == 0 ? Colors.green : (score == 1 ? Colors.orange : Colors.red);
  String _getRecomendacao(int score) => score == 0 ? 'Anticoagulação não recomendada' : (score == 1 ? 'Considerar anticoagulação' : 'Anticoagulação recomendada');

  void _salvar() {
    _store.setResult('cha2ds2vasc', _score.toDouble(), classification: _getClassificacao(_score));
    _store.setFormValues('cha2ds2vasc', {'chf': _chf, 'hypertension': _hypertension, 'age75': _age75, 'diabetes': _diabetes, 'stroke': _stroke, 'vascular': _vascular, 'age65': _age65, 'female': _female});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() { _chf = _hypertension = _age75 = _diabetes = _stroke = _vascular = _age65 = _female = false; });
    _store.clearFormValues('cha2ds2vasc');
    _store.clearResult('cha2ds2vasc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHA₂DS₂-VASc'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScoreDisplay(score: '$_score', classification: _getClassificacao(_score), color: _getColor(_score), subtitle: _getRecomendacao(_score)),
              const SizedBox(height: 24),
              ScoreCheckboxOption(label: 'C - Insuficiência cardíaca', points: '+1', value: _chf, onChanged: (v) => setState(() => _chf = v!)),
              ScoreCheckboxOption(label: 'H - Hipertensão', points: '+1', value: _hypertension, onChanged: (v) => setState(() => _hypertension = v!)),
              ScoreCheckboxOption(label: 'A₂ - Idade ≥ 75 anos', points: '+2', value: _age75, onChanged: (v) => setState(() => _age75 = v!)),
              ScoreCheckboxOption(label: 'D - Diabetes mellitus', points: '+1', value: _diabetes, onChanged: (v) => setState(() => _diabetes = v!)),
              ScoreCheckboxOption(label: 'S₂ - AVC/AIT/Tromboembolismo', points: '+2', value: _stroke, onChanged: (v) => setState(() => _stroke = v!)),
              ScoreCheckboxOption(label: 'V - Doença vascular', points: '+1', value: _vascular, onChanged: (v) => setState(() => _vascular = v!)),
              ScoreCheckboxOption(label: 'A - Idade 65-74 anos', points: '+1', value: _age65, onChanged: (v) => setState(() => _age65 = v!)),
              ScoreCheckboxOption(label: 'Sc - Sexo feminino', points: '+1', value: _female, onChanged: (v) => setState(() => _female = v!)),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HAS-BLED ====================
class HasBledScreen extends StatefulWidget {
  const HasBledScreen({super.key});

  @override
  State<HasBledScreen> createState() => _HasBledScreenState();
}

class _HasBledScreenState extends State<HasBledScreen> {
  final _store = CalculationStore();
  bool _hypertension = false, _renal = false, _liver = false, _stroke = false;
  bool _bleeding = false, _labile = false, _age = false, _drugs = false, _alcohol = false;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('hasbled');
    if (values != null) {
      _hypertension = values['hypertension'] ?? false;
      _renal = values['renal'] ?? false;
      _liver = values['liver'] ?? false;
      _stroke = values['stroke'] ?? false;
      _bleeding = values['bleeding'] ?? false;
      _labile = values['labile'] ?? false;
      _age = values['age'] ?? false;
      _drugs = values['drugs'] ?? false;
      _alcohol = values['alcohol'] ?? false;
    }
  }

  int get _score => [_hypertension, _renal, _liver, _stroke, _bleeding, _labile, _age, _drugs, _alcohol].where((v) => v).length;
  String _getClassificacao(int score) => score <= 1 ? 'Baixo risco sangramento' : (score == 2 ? 'Risco moderado sangramento' : 'Alto risco sangramento');
  Color _getColor(int score) => score <= 1 ? Colors.green : (score == 2 ? Colors.orange : Colors.red);

  void _salvar() {
    _store.setResult('hasbled', _score.toDouble(), classification: _getClassificacao(_score));
    _store.setFormValues('hasbled', {'hypertension': _hypertension, 'renal': _renal, 'liver': _liver, 'stroke': _stroke, 'bleeding': _bleeding, 'labile': _labile, 'age': _age, 'drugs': _drugs, 'alcohol': _alcohol});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() { _hypertension = _renal = _liver = _stroke = _bleeding = _labile = _age = _drugs = _alcohol = false; });
    _store.clearFormValues('hasbled');
    _store.clearResult('hasbled');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HAS-BLED'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScoreDisplay(score: '$_score', classification: _getClassificacao(_score), color: _getColor(_score)),
              const SizedBox(height: 24),
              CheckboxListTile(title: const Text('H - Hipertensão (PAS > 160)'), value: _hypertension, onChanged: (v) => setState(() => _hypertension = v!)),
              CheckboxListTile(title: const Text('A - Função renal anormal'), value: _renal, onChanged: (v) => setState(() => _renal = v!)),
              CheckboxListTile(title: const Text('A - Função hepática anormal'), value: _liver, onChanged: (v) => setState(() => _liver = v!)),
              CheckboxListTile(title: const Text('S - AVC prévio'), value: _stroke, onChanged: (v) => setState(() => _stroke = v!)),
              CheckboxListTile(title: const Text('B - Sangramento prévio'), value: _bleeding, onChanged: (v) => setState(() => _bleeding = v!)),
              CheckboxListTile(title: const Text('L - INR lábil'), value: _labile, onChanged: (v) => setState(() => _labile = v!)),
              CheckboxListTile(title: const Text('E - Idade > 65 anos'), value: _age, onChanged: (v) => setState(() => _age = v!)),
              CheckboxListTile(title: const Text('D - Uso de drogas (AINEs/antiplaq.)'), value: _drugs, onChanged: (v) => setState(() => _drugs = v!)),
              CheckboxListTile(title: const Text('D - Uso de álcool'), value: _alcohol, onChanged: (v) => setState(() => _alcohol = v!)),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== WELLS TEP ====================
class WellsTepScreen extends StatefulWidget {
  const WellsTepScreen({super.key});

  @override
  State<WellsTepScreen> createState() => _WellsTepScreenState();
}

class _WellsTepScreenState extends State<WellsTepScreen> {
  final _store = CalculationStore();
  bool _dvtSymptoms = false, _noAlternative = false, _hr100 = false;
  bool _immobilization = false, _previousDvtPe = false, _hemoptysis = false, _malignancy = false;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('wells_tep');
    if (values != null) {
      _dvtSymptoms = values['dvtSymptoms'] ?? false;
      _noAlternative = values['noAlternative'] ?? false;
      _hr100 = values['hr100'] ?? false;
      _immobilization = values['immobilization'] ?? false;
      _previousDvtPe = values['previousDvtPe'] ?? false;
      _hemoptysis = values['hemoptysis'] ?? false;
      _malignancy = values['malignancy'] ?? false;
    }
  }

  double get _score {
    double s = 0;
    if (_dvtSymptoms) s += 3;
    if (_noAlternative) s += 3;
    if (_hr100) s += 1.5;
    if (_immobilization) s += 1.5;
    if (_previousDvtPe) s += 1.5;
    if (_hemoptysis) s += 1;
    if (_malignancy) s += 1;
    return s;
  }

  String _getClassificacao(double score) => score <= 1 ? 'Baixa probabilidade' : (score <= 6 ? 'Probabilidade moderada' : 'Alta probabilidade');
  Color _getColor(double score) => score <= 1 ? Colors.green : (score <= 6 ? Colors.orange : Colors.red);
  String _getProbabilidade(double score) => score <= 1 ? '~1.3% chance de TEP' : (score <= 6 ? '~16.2% chance de TEP' : '~37.5% chance de TEP');

  void _salvar() {
    _store.setResult('wells_tep', _score, classification: _getClassificacao(_score));
    _store.setFormValues('wells_tep', {'dvtSymptoms': _dvtSymptoms, 'noAlternative': _noAlternative, 'hr100': _hr100, 'immobilization': _immobilization, 'previousDvtPe': _previousDvtPe, 'hemoptysis': _hemoptysis, 'malignancy': _malignancy});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() { _dvtSymptoms = _noAlternative = _hr100 = _immobilization = _previousDvtPe = _hemoptysis = _malignancy = false; });
    _store.clearFormValues('wells_tep');
    _store.clearResult('wells_tep');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wells - TEP'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScoreDisplay(score: _score.toStringAsFixed(1), classification: _getClassificacao(_score), color: _getColor(_score), subtitle: _getProbabilidade(_score)),
              const SizedBox(height: 24),
              ScoreCheckboxOption(label: 'Sinais/sintomas clínicos de TVP', points: '+3', value: _dvtSymptoms, onChanged: (v) => setState(() => _dvtSymptoms = v!)),
              ScoreCheckboxOption(label: 'TEP é o diagnóstico mais provável', points: '+3', value: _noAlternative, onChanged: (v) => setState(() => _noAlternative = v!)),
              ScoreCheckboxOption(label: 'FC > 100 bpm', points: '+1.5', value: _hr100, onChanged: (v) => setState(() => _hr100 = v!)),
              ScoreCheckboxOption(label: 'Imobilização/cirurgia nas últimas 4 sem', points: '+1.5', value: _immobilization, onChanged: (v) => setState(() => _immobilization = v!)),
              ScoreCheckboxOption(label: 'TVP/TEP prévios', points: '+1.5', value: _previousDvtPe, onChanged: (v) => setState(() => _previousDvtPe = v!)),
              ScoreCheckboxOption(label: 'Hemoptise', points: '+1', value: _hemoptysis, onChanged: (v) => setState(() => _hemoptysis = v!)),
              ScoreCheckboxOption(label: 'Malignidade', points: '+1', value: _malignancy, onChanged: (v) => setState(() => _malignancy = v!)),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
            ],
          ),
        ),
      ),
    );
  }
}
