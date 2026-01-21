import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// Simple store for calculation results
class CalculationStore extends ChangeNotifier {
  static final CalculationStore _instance = CalculationStore._internal();
  factory CalculationStore() => _instance;
  CalculationStore._internal();

  final Map<String, double?> _results = {};
  final Map<String, String?> _classifications = {};

  double? getResult(String key) => _results[key];
  String? getClassification(String key) => _classifications[key];

  void setResult(String key, double value, {String? classification}) {
    _results[key] = value;
    _classifications[key] = classification;
    notifyListeners();
  }

  void clearResult(String key) {
    _results.remove(key);
    _classifications.remove(key);
    notifyListeners();
  }

  void clearAll() {
    _results.clear();
    _classifications.clear();
    notifyListeners();
  }

  bool hasResult(String key) => _results.containsKey(key) && _results[key] != null;
  
  bool get hasAnyResult => _results.values.any((v) => v != null);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantaoFacil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeSection(),
    Center(child: Text('Buscar')),
    Center(child: Text('Favoritos')),
    Center(child: Text('Perfil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? page;
  final String? storeKey;
  final String? resultUnit;

  const HomeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.page,
    this.storeKey,
    this.resultUnit,
  });
}

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final CalculationStore _store = CalculationStore();

  static final List<HomeItem> _items = [
    const HomeItem(
      title: 'Calculadora IMC',
      subtitle: 'Índice de Massa Corporal',
      icon: Icons.monitor_weight_outlined,
      page: ImcCalculatorScreen(),
      storeKey: 'imc',
      resultUnit: '',
    ),
    const HomeItem(
      title: 'Clearance Creatinina',
      subtitle: 'Função Renal',
      icon: Icons.water_drop_outlined,
      page: CreatinineClearanceScreen(),
      storeKey: 'creatinine_clearance',
      resultUnit: 'mL/min',
    ),
    const HomeItem(title: 'Item 3', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 4', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 5', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 6', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 7', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 8', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 9', subtitle: 'Em breve', icon: Icons.widgets_outlined),
    const HomeItem(title: 'Item 10', subtitle: 'Em breve', icon: Icons.widgets_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyResult = _store.hasAnyResult;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Início',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (hasAnyResult)
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Limpar tudo'),
                          content: const Text('Deseja limpar todos os resultados salvos?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                _store.clearAll();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Todos os resultados foram limpos'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Limpar tudo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final hasResult = item.storeKey != null && _store.hasResult(item.storeKey!);
                  final result = item.storeKey != null ? _store.getResult(item.storeKey!) : null;
                  final classification = item.storeKey != null ? _store.getClassification(item.storeKey!) : null;
                  
                  return _GridItem(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    result: result,
                    resultUnit: item.resultUnit,
                    classification: classification,
                    hasResult: hasResult,
                    onTap: () {
                      if (item.page != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item.page!),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.title} - Em breve'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    onClear: hasResult && item.storeKey != null
                        ? () {
                            _store.clearResult(item.storeKey!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Resultado limpo'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final double? result;
  final String? resultUnit;
  final String? classification;
  final bool hasResult;
  final VoidCallback? onClear;

  const _GridItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.result,
    this.resultUnit,
    this.classification,
    this.hasResult = false,
    this.onClear,
  });

  Color _getClassificationColor(String? classification) {
    if (classification == null) return Colors.grey;
    switch (classification) {
      // IMC classifications
      case 'Abaixo do peso':
        return Colors.orange;
      case 'Peso normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidade Grau I':
        return Colors.deepOrange;
      case 'Obesidade Grau II':
        return Colors.red;
      case 'Obesidade Grau III':
        return Colors.red.shade900;
      // Creatinine Clearance classifications
      case 'Normal (G1)':
        return Colors.green;
      case 'Levemente diminuída (G2)':
        return Colors.lightGreen;
      case 'Leve a moderada (G3a)':
        return Colors.orange;
      case 'Moderada a severa (G3b)':
        return Colors.deepOrange;
      case 'Severamente diminuída (G4)':
        return Colors.red;
      case 'Falência Renal (G5)':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final classificationColor = _getClassificationColor(classification);
    
    return Material(
      color: hasResult 
          ? classificationColor.withOpacity(0.15)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: hasResult 
                ? Border.all(color: classificationColor.withOpacity(0.5), width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasResult && result != null) ...[
                      Text(
                        result!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: classificationColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classification ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: classificationColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Icon(
                        icon,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              if (hasResult && onClear != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onClear,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(28, 28),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// IMC Calculator Screen
class ImcCalculatorScreen extends StatefulWidget {
  const ImcCalculatorScreen({super.key});

  @override
  State<ImcCalculatorScreen> createState() => _ImcCalculatorScreenState();
}

class _ImcCalculatorScreenState extends State<ImcCalculatorScreen> {
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  double? _imc;
  String _classificacao = '';
  Color _classificacaoColor = Colors.grey;

  void _calcularIMC() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final altura = double.tryParse(_alturaController.text.replaceAll(',', '.'));

    if (peso == null || altura == null || altura == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira valores válidos'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Save result to store
    CalculationStore().setResult('imc', imc, classification: classificacao);
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
        title: const Text('Calculadora IMC'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
              'Índice de Massa Corporal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pesoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ex: 70',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alturaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Altura (m ou cm)',
                hintText: 'Ex: 1.75 ou 175',
                prefixIcon: const Icon(Icons.height),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _calcularIMC,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _limpar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_imc != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _classificacaoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _classificacaoColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Seu IMC',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _imc!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _classificacaoColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _classificacao,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _classificacaoColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildImcTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImcTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              'Tabela de Classificação',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildTableRow('Abaixo de 18.5', 'Abaixo do peso', Colors.orange),
          _buildTableRow('18.5 - 24.9', 'Peso normal', Colors.green),
          _buildTableRow('25.0 - 29.9', 'Sobrepeso', Colors.orange),
          _buildTableRow('30.0 - 34.9', 'Obesidade Grau I', Colors.deepOrange),
          _buildTableRow('35.0 - 39.9', 'Obesidade Grau II', Colors.red),
          _buildTableRow('40.0 ou mais', 'Obesidade Grau III', Colors.red.shade900, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTableRow(String imc, String classificacao, Color color, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              imc,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            classificacao,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

// Creatinine Clearance Calculator Screen (Cockcroft-Gault)
class CreatinineClearanceScreen extends StatefulWidget {
  const CreatinineClearanceScreen({super.key});

  @override
  State<CreatinineClearanceScreen> createState() => _CreatinineClearanceScreenState();
}

class _CreatinineClearanceScreenState extends State<CreatinineClearanceScreen> {
  final _idadeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _creatininaController = TextEditingController();
  bool _isFemale = false;
  double? _clearance;
  String _classificacao = '';
  Color _classificacaoColor = Colors.grey;

  void _calcularClearance() {
    final idade = int.tryParse(_idadeController.text);
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final creatinina = double.tryParse(_creatininaController.text.replaceAll(',', '.'));

    if (idade == null || peso == null || creatinina == null || creatinina == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira valores válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cockcroft-Gault Formula
    double clearance = ((140 - idade) * peso) / (72 * creatinina);
    if (_isFemale) {
      clearance *= 0.85;
    }

    final classificacao = _getClassificacao(clearance);

    setState(() {
      _clearance = clearance;
      _classificacao = classificacao;
      _classificacaoColor = _getClassificacaoColor(clearance);
    });

    // Save result to store
    CalculationStore().setResult('creatinine_clearance', clearance, classification: classificacao);
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _idadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Idade (anos)',
                hintText: 'Ex: 45',
                prefixIcon: const Icon(Icons.cake_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pesoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ex: 70',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creatininaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Creatinina Sérica (mg/dL)',
                hintText: 'Ex: 1.2',
                prefixIcon: const Icon(Icons.science_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Masculino'),
                          icon: Icon(Icons.male),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Feminino'),
                          icon: Icon(Icons.female),
                        ),
                      ],
                      selected: {_isFemale},
                      onSelectionChanged: (Set<bool> selection) {
                        setState(() {
                          _isFemale = selection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _calcularClearance,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _limpar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_clearance != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _classificacaoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _classificacaoColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Clearance de Creatinina',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _clearance!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _classificacaoColor,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'mL/min',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _classificacaoColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _classificacao,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _classificacaoColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildClearanceTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClearanceTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              'Classificação - Doença Renal Crônica',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildTableRow('≥ 90 mL/min', 'Normal (G1)', Colors.green),
          _buildTableRow('60-89 mL/min', 'Levemente diminuída (G2)', Colors.lightGreen),
          _buildTableRow('45-59 mL/min', 'Leve a moderada (G3a)', Colors.orange),
          _buildTableRow('30-44 mL/min', 'Moderada a severa (G3b)', Colors.deepOrange),
          _buildTableRow('15-29 mL/min', 'Severamente diminuída (G4)', Colors.red),
          _buildTableRow('< 15 mL/min', 'Falência Renal (G5)', Colors.red.shade900, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTableRow(String value, String classificacao, Color color, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Flexible(
            child: Text(
              classificacao,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
