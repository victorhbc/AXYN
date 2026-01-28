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
      if (values['peso']?.isNotEmpty == true)
        _pesoController.text = values['peso'];
      _doseController.text = values['dose'] ?? '';
      _resultado = values['resultado'];
    }
  }

  void _calcular() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final doseMgKg = double.tryParse(_doseController.text.replaceAll(',', '.'));
    if (peso == null || doseMgKg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira valores válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final resultado = peso * doseMgKg;
    setState(() => _resultado = resultado);
    _store.setResult('dose_peso', resultado, classification: 'Calculado');
    _store.setSharedPeso(_pesoController.text);
    _store.setFormValues('dose_peso', {
      'peso': _pesoController.text,
      'dose': _doseController.text,
      'resultado': _resultado,
    });
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
              Icon(
                Icons.medication_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Cálculo de Dose',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _pesoController,
                labelText: 'Peso (kg)',
                hintText: 'Ex: 70',
                prefixIcon: Icons.fitness_center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _doseController,
                labelText: 'Dose (mg/kg)',
                hintText: 'Ex: 10',
                prefixIcon: Icons.science_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 24),
              CalculateButtons(onCalculate: _calcular, onClear: _limpar),
              if (_resultado != null) ...[
                const SizedBox(height: 32),
                ResultCard(
                  title: 'Dose Total',
                  value: _resultado!.toStringAsFixed(1),
                  unit: 'mg',
                  color: Colors.blue,
                ),
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
  int _ocular = 0, _verbal = 0, _motor = 0, _pupil = 0;

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('glasgow');
    if (values != null) {
      _ocular = values['ocular'] ?? 0;
      _verbal = values['verbal'] ?? 0;
      _motor = values['motor'] ?? 0;
      _pupil = values['pupil'] ?? 0;
    }
  }

  int get _total => _ocular + _verbal + _motor;

  // GCS-P (Glasgow Coma Scale - Pupils) = GCS Score - Pupil Reactivity Score
  // Pupil Reactivity Score: 0 = both reactive, 1 = one not reactive, 2 = both not reactive
  int get _gcsP {
    if (_total == 0) return 0;
    final result = _total - _pupil;
    return result.clamp(1, 15);
  }

  String _getClassificacao(int score) {
    if (score >= 13) return 'TCE Leve';
    if (score >= 9) return 'TCE Moderado';
    if (score >= 3) return 'TCE Grave';
    return 'Sem resposta';
  }

  Color _getColor(int score) {
    if (score >= 13) return Colors.green;
    if (score >= 9) return Colors.orange;
    if (score >= 3) return Colors.red;
    return Colors.red.shade900;
  }

  String _getSeveridade(int score) {
    if (score >= 13) return 'Leve (13-15)';
    if (score >= 9) return 'Moderado (9-12)';
    if (score >= 3) return 'Grave (3-8)';
    return 'Sem resposta';
  }

  String _getPrognostico(int score) {
    if (score >= 13) {
      return 'Bom prognóstico. Monitoramento ambulatorial geralmente adequado.';
    } else if (score >= 9) {
      return 'Prognóstico variável. Requer monitoramento hospitalar e avaliação neurológica seriada.';
    } else if (score >= 3) {
      return 'Prognóstico reservado. Requer cuidados intensivos e monitoramento neurológico contínuo.';
    }
    return 'Prognóstico muito reservado. Necessita cuidados intensivos imediatos.';
  }

  void _salvar() {
    if (_total > 0) {
      _store.setResult(
        'glasgow',
        _total.toDouble(),
        classification: _getClassificacao(_total),
      );
      _store.setFormValues('glasgow', {
        'ocular': _ocular,
        'verbal': _verbal,
        'motor': _motor,
        'pupil': _pupil,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado salvo'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _limpar() {
    setState(() {
      _ocular = _verbal = _motor = _pupil = 0;
    });
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
              if (_total > 0) ...[
                ScoreDisplay(
                  score: _pupil > 0 ? '$_gcsP' : '$_total',
                  classification: _pupil > 0
                      ? _getClassificacao(_gcsP)
                      : _getClassificacao(_total),
                  color: _pupil > 0 ? _getColor(_gcsP) : _getColor(_total),
                  subtitle: _pupil > 0
                      ? 'GCS-P: $_gcsP (GCS $_total - Pupil Reactivity $_pupil)\n${_getSeveridade(_gcsP)}\n${_getPrognostico(_gcsP)}'
                      : '${_getSeveridade(_total)}\n${_getPrognostico(_total)}',
                ),
                const SizedBox(height: 16),
                _buildComponentBreakdown(context),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Escala de Glasgow',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecione as respostas abaixo para calcular o escore',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SectionCard(
                title: 'Abertura Ocular',
                children: [
                  _buildRadio(
                    'Espontânea',
                    4,
                    _ocular,
                    (v) => setState(() => _ocular = v!),
                  ),
                  _buildRadio(
                    'Ao estímulo verbal',
                    3,
                    _ocular,
                    (v) => setState(() => _ocular = v!),
                  ),
                  _buildRadio(
                    'Ao estímulo doloroso',
                    2,
                    _ocular,
                    (v) => setState(() => _ocular = v!),
                  ),
                  _buildRadio(
                    'Ausente',
                    1,
                    _ocular,
                    (v) => setState(() => _ocular = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Resposta Verbal',
                children: [
                  _buildRadio(
                    'Orientada',
                    5,
                    _verbal,
                    (v) => setState(() => _verbal = v!),
                  ),
                  _buildRadio(
                    'Confusa',
                    4,
                    _verbal,
                    (v) => setState(() => _verbal = v!),
                  ),
                  _buildRadio(
                    'Palavras inapropriadas',
                    3,
                    _verbal,
                    (v) => setState(() => _verbal = v!),
                  ),
                  _buildRadio(
                    'Sons incompreensíveis',
                    2,
                    _verbal,
                    (v) => setState(() => _verbal = v!),
                  ),
                  _buildRadio(
                    'Ausente',
                    1,
                    _verbal,
                    (v) => setState(() => _verbal = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Resposta Motora',
                children: [
                  _buildRadio(
                    'Obedece comandos',
                    6,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                  _buildRadio(
                    'Localiza dor',
                    5,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                  _buildRadio(
                    'Movimento de retirada',
                    4,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                  _buildRadio(
                    'Flexão anormal',
                    3,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                  _buildRadio(
                    'Extensão anormal',
                    2,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                  _buildRadio(
                    'Ausente',
                    1,
                    _motor,
                    (v) => setState(() => _motor = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Resposta Pupilar',
                children: [
                  _buildRadio(
                    'Ambas pupilas reativas',
                    0,
                    _pupil,
                    (v) => setState(() => _pupil = v!),
                  ),
                  _buildRadio(
                    'Uma pupila não reativa',
                    1,
                    _pupil,
                    (v) => setState(() => _pupil = v!),
                  ),
                  _buildRadio(
                    'Ambas pupilas não reativas',
                    2,
                    _pupil,
                    (v) => setState(() => _pupil = v!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SaveClearButtons(
                onSave: _total > 0 ? _salvar : null,
                onClear: _limpar,
              ),
              if (_total > 0) ...[
                const SizedBox(height: 32),
                _buildSeverityTable(context),
                const SizedBox(height: 24),
                _buildDetailsCard(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentBreakdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildComponentItem(context, 'Ocular', _ocular, 4),
          _buildComponentItem(context, 'Verbal', _verbal, 5),
          _buildComponentItem(context, 'Motor', _motor, 6),
          if (_pupil > 0)
            _buildComponentItem(context, 'Pupila', _pupil, 2, isPupil: true),
        ],
      ),
    );
  }

  Widget _buildComponentItem(
    BuildContext context,
    String label,
    int value,
    int max, {
    bool isPupil = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          isPupil ? '-$value' : '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPupil ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          '/$max',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSeverityTable(BuildContext context) {
    return ClassificationTable(
      title: 'Classificação por Escore',
      rows: [
        const TableRowData(
          value: '13-15',
          label: 'TCE Leve',
          color: Colors.green,
        ),
        const TableRowData(
          value: '9-12',
          label: 'TCE Moderado',
          color: Colors.orange,
        ),
        const TableRowData(value: '3-8', label: 'TCE Grave', color: Colors.red),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sobre a Escala de Glasgow',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'A Escala de Coma de Glasgow (GCS) é uma ferramenta neurológica usada para avaliar o nível de consciência após um traumatismo cranioencefálico (TCE).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Componentes:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• Abertura Ocular (1-4):',
            'Avalia a capacidade de abrir os olhos espontaneamente ou em resposta a estímulos.',
          ),
          _buildDetailItem(
            context,
            '• Resposta Verbal (1-5):',
            'Avalia a capacidade de comunicação e orientação.',
          ),
          _buildDetailItem(
            context,
            '• Resposta Motora (1-6):',
            'Avalia a capacidade de movimento e resposta a comandos ou estímulos.',
          ),
          _buildDetailItem(
            context,
            '• Resposta Pupilar (0-2):',
            'Avalia a reatividade pupilar à luz. Ambas reativas (0), uma não reativa (1), ambas não reativas (2). O GCS-P é calculado subtraindo o escore pupilar do GCS total.',
          ),
          const SizedBox(height: 12),
          Text(
            'Interpretação:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• 13-15 (Leve):',
            'Bom prognóstico. Geralmente não requer hospitalização prolongada.',
          ),
          _buildDetailItem(
            context,
            '• 9-12 (Moderado):',
            'Prognóstico variável. Requer monitoramento hospitalar e avaliação neurológica seriada.',
          ),
          _buildDetailItem(
            context,
            '• 3-8 (Grave):',
            'Prognóstico reservado. Necessita cuidados intensivos e monitoramento neurológico contínuo.',
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            context,
            '• GCS-P (Glasgow Coma Scale - Pupils):',
            'Versão estendida que incorpora a reatividade pupilar. Calculado como GCS - Escore de Reatividade Pupilar. Valores de 1-15, com valores menores indicando pior prognóstico.',
          ),
          const SizedBox(height: 12),
          Text(
            'Nota: O escore deve ser reavaliado seriamente, pois pode mudar rapidamente. A resposta motora é o componente mais preditivo de prognóstico em pacientes com TCE grave. A combinação do GCS com a reatividade pupilar (GCS-P) fornece melhor predição de desfecho do que qualquer componente isolado.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(
    String label,
    int value,
    int groupValue,
    ValueChanged<int?> onChanged,
  ) {
    return RadioListTile<int>(
      title: Text(label),
      secondary: Text(
        '$value',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      dense: true,
    );
  }
}

// ==================== CHA2DS2-VA ====================
class Cha2ds2VaScreen extends StatefulWidget {
  const Cha2ds2VaScreen({super.key});

  @override
  State<Cha2ds2VaScreen> createState() => _Cha2ds2VaScreenState();
}

class _Cha2ds2VaScreenState extends State<Cha2ds2VaScreen> {
  final _store = CalculationStore();
  bool _chf = false, _hypertension = false, _diabetes = false;
  bool _stroke = false, _vascular = false;
  int _ageCategory = -1; // -1 = not selected, 0 = under 65, 1 = 65-74, 2 = ≥75

  @override
  void initState() {
    super.initState();
    final values = _store.getFormValues('cha2ds2va');
    if (values != null) {
      _chf = values['chf'] ?? false;
      _hypertension = values['hypertension'] ?? false;
      _diabetes = values['diabetes'] ?? false;
      _stroke = values['stroke'] ?? false;
      _vascular = values['vascular'] ?? false;
      _ageCategory = values['ageCategory'] != null
          ? values['ageCategory'] as int
          : -1;
    }
  }

  int get _score {
    int s = 0;
    if (_chf) s += 1;
    if (_hypertension) s += 1;
    if (_diabetes) s += 1;
    if (_stroke) s += 2;
    if (_vascular) s += 1;
    // Age points: 0 = under 65 (0 points), 1 = 65-74 (1 point), 2 = ≥75 (2 points)
    if (_ageCategory == 1) s += 1;
    if (_ageCategory == 2) s += 2;
    return s;
  }

  /// Returns the annual stroke risk percentage based on CHA2DS2-VA score
  double _getAnnualStrokeRisk(int score) {
    const riskMap = {
      0: 0.2,
      1: 0.6,
      2: 2.2,
      3: 3.2,
      4: 4.8,
      5: 7.2,
      6: 9.7,
      7: 11.2,
      8: 10.8,
    };
    return riskMap[score.clamp(0, 8)] ?? 10.8;
  }

  String _getClassificacao(int score) {
    if (score == 0) return 'Baixo risco';
    if (score == 1) return 'Risco baixo-moderado';
    if (score == 2) return 'Risco moderado';
    return 'Alto risco';
  }

  Color _getColor(int score) {
    if (score == 0) return Colors.green;
    if (score == 1) return Colors.lightGreen;
    if (score == 2) return Colors.orange;
    return Colors.red;
  }

  String _getRecomendacao(int score) {
    final risk = _getAnnualStrokeRisk(score);
    if (score == 0) {
      return 'Anticoagulação não recomendada';
    } else if (score == 1) {
      return 'Considerar anticoagulação (risco baixo)';
    } else if (risk < 2.0) {
      return 'Considerar anticoagulação';
    } else {
      return 'Anticoagulação recomendada';
    }
  }

  void _salvar() {
    _store.setResult(
      'cha2ds2va',
      _score.toDouble(),
      classification: _getClassificacao(_score),
    );
    _store.setFormValues('cha2ds2va', {
      'chf': _chf,
      'hypertension': _hypertension,
      'diabetes': _diabetes,
      'stroke': _stroke,
      'vascular': _vascular,
      'ageCategory': _ageCategory,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado salvo'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _limpar() {
    setState(() {
      _chf = _hypertension = _diabetes = _stroke = _vascular = false;
      _ageCategory = -1;
    });
    _store.clearFormValues('cha2ds2va');
    _store.clearResult('cha2ds2va');
  }

  @override
  Widget build(BuildContext context) {
    final annualRisk = _getAnnualStrokeRisk(_score);
    final riskPercentage = annualRisk.toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text('CHA₂DS₂-VA'), centerTitle: true),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScoreDisplay(
                score: '$_score',
                classification: _getClassificacao(_score),
                color: _getColor(_score),
                subtitle:
                    'Risco anual de AVC: $riskPercentage%\n${_getRecomendacao(_score)}',
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Idade',
                children: [
                  ScoreRadioOption<int>(
                    label: 'Menor que 65 anos',
                    value: 0,
                    groupValue: _ageCategory,
                    onChanged: (v) {
                      if (v != null) setState(() => _ageCategory = v);
                    },
                    points: 0,
                  ),
                  ScoreRadioOption<int>(
                    label: '65 a 74 anos',
                    value: 1,
                    groupValue: _ageCategory,
                    onChanged: (v) {
                      if (v != null) setState(() => _ageCategory = v);
                    },
                    points: 1,
                  ),
                  ScoreRadioOption<int>(
                    label: '≥ 75 anos',
                    value: 2,
                    groupValue: _ageCategory,
                    onChanged: (v) {
                      if (v != null) setState(() => _ageCategory = v);
                    },
                    points: 2,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ScoreCheckboxOption(
                label: 'C - Insuficiência cardíaca',
                points: '+1',
                value: _chf,
                onChanged: (v) => setState(() => _chf = v!),
              ),
              ScoreCheckboxOption(
                label: 'H - Hipertensão',
                points: '+1',
                value: _hypertension,
                onChanged: (v) => setState(() => _hypertension = v!),
              ),
              ScoreCheckboxOption(
                label: 'D - Diabetes mellitus',
                points: '+1',
                value: _diabetes,
                onChanged: (v) => setState(() => _diabetes = v!),
              ),
              ScoreCheckboxOption(
                label: 'S₂ - AVC/AIT/Tromboembolismo',
                points: '+2',
                value: _stroke,
                onChanged: (v) => setState(() => _stroke = v!),
              ),
              ScoreCheckboxOption(
                label: 'V - Doença vascular',
                points: '+1',
                value: _vascular,
                onChanged: (v) => setState(() => _vascular = v!),
              ),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
              const SizedBox(height: 32),
              _buildRiskTable(context),
              const SizedBox(height: 24),
              _buildDetailsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskTable(BuildContext context) {
    return ClassificationTable(
      title: 'Risco Anual de AVC por Escore',
      rows: [
        const TableRowData(
          value: 'Escore 0',
          label: '0.2% ao ano',
          color: Colors.green,
        ),
        const TableRowData(
          value: 'Escore 1',
          label: '0.6% ao ano',
          color: Colors.lightGreen,
        ),
        const TableRowData(
          value: 'Escore 2',
          label: '2.2% ao ano',
          color: Colors.orange,
        ),
        const TableRowData(
          value: 'Escore 3',
          label: '3.2% ao ano',
          color: Colors.deepOrange,
        ),
        const TableRowData(
          value: 'Escore 4',
          label: '4.8% ao ano',
          color: Colors.red,
        ),
        const TableRowData(
          value: 'Escore 5',
          label: '7.2% ao ano',
          color: Colors.red,
        ),
        const TableRowData(
          value: 'Escore 6',
          label: '9.7% ao ano',
          color: Colors.red,
        ),
        const TableRowData(
          value: 'Escore 7',
          label: '11.2% ao ano',
          color: Colors.red,
        ),
        const TableRowData(
          value: 'Escore 8',
          label: '10.8% ao ano',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sobre o CHA₂DS₂-VA',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'O escore CHA₂DS₂-VA estima o risco anual de acidente vascular cerebral (AVC) em pacientes com fibrilação atrial não valvar. Esta versão atualizada remove o componente de sexo (Sc) do escore anterior CHA₂DS₂-VASc, baseado em evidências recentes que mostram que o sexo feminino não é um fator de risco independente para AVC.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Interpretação:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• Escore 0:',
            'Risco muito baixo. Anticoagulação não recomendada.',
          ),
          _buildDetailItem(
            context,
            '• Escore 1:',
            'Risco baixo. Considerar anticoagulação baseado em fatores individuais.',
          ),
          _buildDetailItem(
            context,
            '• Escore ≥2:',
            'Risco aumentado. Anticoagulação geralmente recomendada (risco >2% ao ano).',
          ),
          const SizedBox(height: 12),
          Text(
            'Nota: Este escore é uma ferramenta de auxílio à decisão clínica. A decisão final sobre anticoagulação deve considerar fatores individuais do paciente, incluindo risco de sangramento (HAS-BLED).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
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
  bool _bleeding = false,
      _labile = false,
      _age = false,
      _drugs = false,
      _alcohol = false;

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

  int get _score => [
    _hypertension,
    _renal,
    _liver,
    _stroke,
    _bleeding,
    _labile,
    _age,
    _drugs,
    _alcohol,
  ].where((v) => v).length;

  /// Returns the annual major bleeding risk percentage based on HAS-BLED score
  double _getAnnualBleedingRisk(int score) {
    const riskMap = {0: 1.13, 1: 1.02, 2: 1.88, 3: 3.74, 4: 8.70};
    // For scores 5-9, use the highest known risk (score 4) as estimate
    return riskMap[score.clamp(0, 4)] ?? 8.70;
  }

  String _getClassificacao(int score) {
    if (score <= 1) return 'Baixo risco';
    if (score == 2) return 'Risco moderado';
    return 'Alto risco';
  }

  Color _getColor(int score) {
    if (score <= 1) return Colors.green;
    if (score == 2) return Colors.orange;
    return Colors.red;
  }

  String _getRecomendacao(int score) {
    if (score <= 1) {
      return 'Risco aceitável de sangramento. Anticoagulação geralmente segura.';
    } else if (score == 2) {
      return 'Risco moderado. Monitorar cuidadosamente e considerar modificar fatores de risco.';
    } else {
      return 'Risco elevado. Revisar necessidade de anticoagulação e corrigir fatores de risco modificáveis.';
    }
  }

  void _salvar() {
    _store.setResult(
      'hasbled',
      _score.toDouble(),
      classification: _getClassificacao(_score),
    );
    _store.setFormValues('hasbled', {
      'hypertension': _hypertension,
      'renal': _renal,
      'liver': _liver,
      'stroke': _stroke,
      'bleeding': _bleeding,
      'labile': _labile,
      'age': _age,
      'drugs': _drugs,
      'alcohol': _alcohol,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado salvo'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _limpar() {
    setState(() {
      _hypertension = _renal = _liver = _stroke = _bleeding = _labile = _age =
          _drugs = _alcohol = false;
    });
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
              ScoreDisplay(
                score: '$_score',
                classification: _getClassificacao(_score),
                color: _getColor(_score),
                subtitle:
                    'Risco anual de sangramento: ${_getAnnualBleedingRisk(_score).toStringAsFixed(2)}%\n${_getRecomendacao(_score)}',
              ),
              const SizedBox(height: 24),
              ScoreCheckboxOption(
                label: 'H - Hipertensão (PAS > 160)',
                points: '+1',
                value: _hypertension,
                onChanged: (v) => setState(() => _hypertension = v!),
              ),
              ScoreCheckboxOption(
                label: 'A - Função renal anormal',
                points: '+1',
                value: _renal,
                onChanged: (v) => setState(() => _renal = v!),
              ),
              ScoreCheckboxOption(
                label: 'A - Função hepática anormal',
                points: '+1',
                value: _liver,
                onChanged: (v) => setState(() => _liver = v!),
              ),
              ScoreCheckboxOption(
                label: 'S - AVC prévio',
                points: '+1',
                value: _stroke,
                onChanged: (v) => setState(() => _stroke = v!),
              ),
              ScoreCheckboxOption(
                label: 'B - Sangramento prévio',
                points: '+1',
                value: _bleeding,
                onChanged: (v) => setState(() => _bleeding = v!),
              ),
              ScoreCheckboxOption(
                label: 'L - INR lábil',
                points: '+1',
                value: _labile,
                onChanged: (v) => setState(() => _labile = v!),
              ),
              ScoreCheckboxOption(
                label: 'E - Idade > 65 anos',
                points: '+1',
                value: _age,
                onChanged: (v) => setState(() => _age = v!),
              ),
              ScoreCheckboxOption(
                label: 'D - Uso de drogas (AINEs/antiplaq.)',
                points: '+1',
                value: _drugs,
                onChanged: (v) => setState(() => _drugs = v!),
              ),
              ScoreCheckboxOption(
                label: 'D - Uso de álcool',
                points: '+1',
                value: _alcohol,
                onChanged: (v) => setState(() => _alcohol = v!),
              ),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
              const SizedBox(height: 32),
              _buildRiskTable(context),
              const SizedBox(height: 24),
              _buildDetailsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskTable(BuildContext context) {
    return ClassificationTable(
      title: 'Risco Anual de Sangramento por Escore',
      rows: [
        const TableRowData(
          value: 'Escore 0',
          label: '1.13% ao ano',
          color: Colors.green,
        ),
        const TableRowData(
          value: 'Escore 1',
          label: '1.02% ao ano',
          color: Colors.green,
        ),
        const TableRowData(
          value: 'Escore 2',
          label: '1.88% ao ano',
          color: Colors.orange,
        ),
        const TableRowData(
          value: 'Escore 3',
          label: '3.74% ao ano',
          color: Colors.red,
        ),
        const TableRowData(
          value: 'Escore 4',
          label: '8.70% ao ano',
          color: Colors.red,
        ),
        TableRowData(
          value: 'Escore ≥5',
          label: 'Risco muito elevado',
          color: Colors.red.shade900,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sobre o HAS-BLED',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'O escore HAS-BLED estima o risco anual de sangramento maior em pacientes em uso de anticoagulantes, especialmente na fibrilação atrial.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Componentes:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• H - Hipertensão:',
            'Pressão arterial sistólica não controlada (>160 mmHg).',
          ),
          _buildDetailItem(
            context,
            '• A - Função anormal:',
            'Função renal ou hepática anormal (cada uma conta 1 ponto).',
          ),
          _buildDetailItem(
            context,
            '• S - AVC prévio:',
            'História prévia de acidente vascular cerebral.',
          ),
          _buildDetailItem(
            context,
            '• B - Sangramento:',
            'História prévia de sangramento ou predisposição.',
          ),
          _buildDetailItem(
            context,
            '• L - INR lábil:',
            'INR instável em pacientes em uso de varfarina.',
          ),
          _buildDetailItem(context, '• E - Idoso:', 'Idade > 65 anos.'),
          _buildDetailItem(
            context,
            '• D - Drogas/Álcool:',
            'Uso de AINEs, antiplaquetários ou álcool excessivo.',
          ),
          const SizedBox(height: 12),
          Text(
            'Interpretação:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• 0-1 (Baixo risco):',
            'Risco anual ~1%. Anticoagulação geralmente segura.',
          ),
          _buildDetailItem(
            context,
            '• 2 (Moderado):',
            'Risco anual ~2%. Monitorar cuidadosamente e modificar fatores de risco.',
          ),
          _buildDetailItem(
            context,
            '• ≥3 (Alto risco):',
            'Risco anual ≥3.7%. Revisar necessidade de anticoagulação e corrigir fatores modificáveis.',
          ),
          const SizedBox(height: 12),
          Text(
            'Nota: O HAS-BLED não deve ser usado para contraindicar anticoagulação, mas sim para identificar e corrigir fatores de risco modificáveis. O benefício da anticoagulação (CHA₂DS₂-VA) deve ser balanceado com o risco de sangramento (HAS-BLED).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
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
  bool _immobilization = false,
      _previousDvtPe = false,
      _hemoptysis = false,
      _malignancy = false;

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

  /// Returns the probability of PE based on Wells score
  double _getPEProbability(double score) {
    if (score <= 1) return 3.6;
    if (score <= 4) return 5.1;
    if (score <= 6) return 20.5;
    return 66.7;
  }

  String _getClassificacao(double score) {
    if (score <= 1) return 'Baixa probabilidade';
    if (score <= 4) return 'Baixa probabilidade';
    if (score <= 6) return 'Probabilidade moderada';
    return 'Alta probabilidade';
  }

  Color _getColor(double score) {
    if (score <= 4) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getProbabilidade(double score) {
    final prob = _getPEProbability(score);
    return 'Probabilidade de TEP: ${prob.toStringAsFixed(1)}%';
  }

  String _getRecomendacao(double score) {
    if (score <= 4) {
      return 'TEP improvável. Considerar D-dímero. Se negativo, TEP pode ser excluído.';
    } else if (score <= 6) {
      return 'TEP possível. Realizar D-dímero e/ou angio-TC de tórax.';
    } else {
      return 'TEP provável. Realizar angio-TC de tórax imediatamente. Considerar anticoagulação empírica.';
    }
  }

  void _salvar() {
    _store.setResult(
      'wells_tep',
      _score,
      classification: _getClassificacao(_score),
    );
    _store.setFormValues('wells_tep', {
      'dvtSymptoms': _dvtSymptoms,
      'noAlternative': _noAlternative,
      'hr100': _hr100,
      'immobilization': _immobilization,
      'previousDvtPe': _previousDvtPe,
      'hemoptysis': _hemoptysis,
      'malignancy': _malignancy,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado salvo'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _limpar() {
    setState(() {
      _dvtSymptoms = _noAlternative = _hr100 = _immobilization =
          _previousDvtPe = _hemoptysis = _malignancy = false;
    });
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
              ScoreDisplay(
                score: _score.toStringAsFixed(1),
                classification: _getClassificacao(_score),
                color: _getColor(_score),
                subtitle:
                    '${_getProbabilidade(_score)}\n${_getRecomendacao(_score)}',
              ),
              const SizedBox(height: 24),
              ScoreCheckboxOption(
                label: 'Sinais/sintomas clínicos de TVP',
                points: '+3',
                value: _dvtSymptoms,
                onChanged: (v) => setState(() => _dvtSymptoms = v!),
              ),
              ScoreCheckboxOption(
                label: 'TEP é o diagnóstico mais provável',
                points: '+3',
                value: _noAlternative,
                onChanged: (v) => setState(() => _noAlternative = v!),
              ),
              ScoreCheckboxOption(
                label: 'FC > 100 bpm',
                points: '+1.5',
                value: _hr100,
                onChanged: (v) => setState(() => _hr100 = v!),
              ),
              ScoreCheckboxOption(
                label: 'Imobilização/cirurgia nas últimas 4 sem',
                points: '+1.5',
                value: _immobilization,
                onChanged: (v) => setState(() => _immobilization = v!),
              ),
              ScoreCheckboxOption(
                label: 'TVP/TEP prévios',
                points: '+1.5',
                value: _previousDvtPe,
                onChanged: (v) => setState(() => _previousDvtPe = v!),
              ),
              ScoreCheckboxOption(
                label: 'Hemoptise',
                points: '+1',
                value: _hemoptysis,
                onChanged: (v) => setState(() => _hemoptysis = v!),
              ),
              ScoreCheckboxOption(
                label: 'Malignidade',
                points: '+1',
                value: _malignancy,
                onChanged: (v) => setState(() => _malignancy = v!),
              ),
              const SizedBox(height: 24),
              SaveClearButtons(onSave: _salvar, onClear: _limpar),
              const SizedBox(height: 32),
              _buildRiskTable(context),
              const SizedBox(height: 24),
              _buildDetailsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskTable(BuildContext context) {
    return ClassificationTable(
      title: 'Probabilidade de TEP por Escore',
      rows: [
        const TableRowData(
          value: 'Escore ≤1',
          label: '3.6% probabilidade',
          color: Colors.green,
        ),
        const TableRowData(
          value: 'Escore 2-4',
          label: '5.1% probabilidade',
          color: Colors.green,
        ),
        const TableRowData(
          value: 'Escore 4.5-6',
          label: '20.5% probabilidade',
          color: Colors.orange,
        ),
        const TableRowData(
          value: 'Escore >6',
          label: '66.7% probabilidade',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sobre o Escore de Wells para TEP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'O escore de Wells estima a probabilidade pré-teste de tromboembolismo pulmonar (TEP) baseado em critérios clínicos.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Componentes:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• Sinais/sintomas de TVP:',
            'Edema ou dor em membro inferior (+3 pontos).',
          ),
          _buildDetailItem(
            context,
            '• TEP mais provável:',
            'TEP é o diagnóstico mais provável que alternativas (+3 pontos).',
          ),
          _buildDetailItem(
            context,
            '• FC > 100 bpm:',
            'Frequência cardíaca > 100 bpm (+1.5 pontos).',
          ),
          _buildDetailItem(
            context,
            '• Imobilização/cirurgia:',
            'Imobilização ≥3 dias ou cirurgia nas últimas 4 semanas (+1.5 pontos).',
          ),
          _buildDetailItem(
            context,
            '• TVP/TEP prévios:',
            'História prévia de trombose venosa profunda ou TEP (+1.5 pontos).',
          ),
          _buildDetailItem(
            context,
            '• Hemoptise:',
            'Sangramento ao tossir (+1 ponto).',
          ),
          _buildDetailItem(
            context,
            '• Malignidade:',
            'Malignidade ativa ou tratamento recente (+1 ponto).',
          ),
          const SizedBox(height: 12),
          Text(
            'Interpretação:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            context,
            '• ≤4 (Baixa probabilidade):',
            'Probabilidade ~3.6-5.1%. Considerar D-dímero. Se negativo, TEP pode ser excluído.',
          ),
          _buildDetailItem(
            context,
            '• 4.5-6 (Moderada):',
            'Probabilidade ~20.5%. Realizar D-dímero e/ou angio-TC de tórax.',
          ),
          _buildDetailItem(
            context,
            '• >6 (Alta probabilidade):',
            'Probabilidade ~66.7%. Realizar angio-TC de tórax imediatamente. Considerar anticoagulação empírica.',
          ),
          const SizedBox(height: 12),
          Text(
            'Nota: O escore de Wells deve ser usado em conjunto com exames complementares (D-dímero, angio-TC). Em pacientes com escore baixo e D-dímero negativo, a probabilidade de TEP é <2%. Em pacientes com escore alto, a investigação deve ser imediata.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
