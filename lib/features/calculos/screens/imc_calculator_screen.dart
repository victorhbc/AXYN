import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/store/calculation_store.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/responsive_layout.dart';

class ImcCalculatorScreen extends StatefulWidget {
  const ImcCalculatorScreen({super.key});

  @override
  State<ImcCalculatorScreen> createState() => _ImcCalculatorScreenState();
}

class _ImcCalculatorScreenState extends State<ImcCalculatorScreen> {
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _store = CalculationStore();
  double? _imc;
  String _classificacao = '';
  Color _classificacaoColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadFormValues();
  }

  void _loadFormValues() {
    if (_store.sharedPeso.isNotEmpty) {
      _pesoController.text = _store.sharedPeso;
    }
    if (_store.sharedAltura.isNotEmpty) {
      _alturaController.text = _store.sharedAltura;
    }
    final values = _store.getFormValues('imc');
    if (values != null) {
      if (values['peso']?.isNotEmpty == true) _pesoController.text = values['peso'];
      if (values['altura']?.isNotEmpty == true) _alturaController.text = values['altura'];
      if (values['imc'] != null) {
        _imc = values['imc'];
        _classificacao = values['classificacao'] ?? '';
        _classificacaoColor = _getClassificacaoColor(_imc!);
      }
    }
  }

  void _saveFormValues() {
    _store.setSharedPeso(_pesoController.text);
    _store.setSharedAltura(_alturaController.text);
    _store.setFormValues('imc', {
      'peso': _pesoController.text,
      'altura': _alturaController.text,
      'imc': _imc,
      'classificacao': _classificacao,
    });
  }

  void _calcularIMC() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final altura = double.tryParse(_alturaController.text.replaceAll(',', '.'));

    if (peso == null || altura == null || altura == 0) {
      _showError(AppStrings.valoresInvalidos);
      return;
    }

    final alturaMetros = altura > 3 ? altura / 100 : altura;
    final imc = peso / (alturaMetros * alturaMetros);
    final classificacao = _getClassificacao(imc);

    setState(() {
      _imc = imc;
      _classificacao = classificacao;
      _classificacaoColor = _getClassificacaoColor(imc);
    });

    _store.setResult('imc', imc, classification: classificacao);
    _saveFormValues();
  }

  String _getClassificacao(double imc) {
    if (imc < 18.5) return 'Abaixo do peso';
    if (imc < 25) return 'Peso normal';
    if (imc < 30) return 'Sobrepeso';
    if (imc < 35) return 'Obesidade Grau I';
    if (imc < 40) return 'Obesidade Grau II';
    return 'Obesidade Grau III';
  }

  Color _getClassificacaoColor(double imc) {
    if (imc < 18.5) return Colors.orange;
    if (imc < 25) return Colors.green;
    if (imc < 30) return Colors.orange;
    if (imc < 35) return Colors.deepOrange;
    if (imc < 40) return Colors.red;
    return Colors.red.shade900;
  }

  void _limpar() {
    setState(() {
      _pesoController.clear();
      _alturaController.clear();
      _imc = null;
      _classificacao = '';
    });
    _store.clearFormValues('imc');
    _store.clearResult('imc');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.imcTitle),
        centerTitle: true,
      ),
      body: ResponsiveContent(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.imcSubtitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _pesoController,
                labelText: AppStrings.pesoKg,
                hintText: 'Ex: 70',
                prefixIcon: Icons.fitness_center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _alturaController,
                labelText: AppStrings.alturaHint,
                hintText: 'Ex: 1.75 ou 175',
                prefixIcon: Icons.height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              CalculateButtons(
                onCalculate: _calcularIMC,
                onClear: _limpar,
              ),
              if (_imc != null) ...[
                const SizedBox(height: 32),
                ResultCard(
                  title: 'Seu IMC',
                  value: _imc!.toStringAsFixed(1),
                  classification: _classificacao,
                  color: _classificacaoColor,
                ),
                const SizedBox(height: 24),
                _buildImcTable(),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                CitationLinkButton(calculatorName: 'IMC'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImcTable() {
    return ClassificationTable(
      title: 'Tabela de Classificação',
      rows: [
        const TableRowData(value: 'Abaixo de 18.5', label: 'Abaixo do peso', color: Colors.orange),
        const TableRowData(value: '18.5 - 24.9', label: 'Peso normal', color: Colors.green),
        const TableRowData(value: '25.0 - 29.9', label: 'Sobrepeso', color: Colors.orange),
        const TableRowData(value: '30.0 - 34.9', label: 'Obesidade Grau I', color: Colors.deepOrange),
        const TableRowData(value: '35.0 - 39.9', label: 'Obesidade Grau II', color: Colors.red),
        TableRowData(value: '40.0 ou mais', label: 'Obesidade Grau III', color: Colors.red.shade900),
      ],
    );
  }
}
