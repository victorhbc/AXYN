import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// Simple store for calculation results and form values
class CalculationStore extends ChangeNotifier {
  static final CalculationStore _instance = CalculationStore._internal();
  factory CalculationStore() => _instance;
  CalculationStore._internal();

  final Map<String, double?> _results = {};
  final Map<String, String?> _classifications = {};
  final Map<String, Map<String, dynamic>> _formValues = {};

  // Shared patient data across calculators
  String _sharedPeso = '';
  String _sharedAltura = '';
  String _sharedIdade = '';

  String get sharedPeso => _sharedPeso;
  String get sharedAltura => _sharedAltura;
  String get sharedIdade => _sharedIdade;

  void setSharedPeso(String value) {
    _sharedPeso = value;
    notifyListeners();
  }

  void setSharedAltura(String value) {
    _sharedAltura = value;
    notifyListeners();
  }

  void setSharedIdade(String value) {
    _sharedIdade = value;
    notifyListeners();
  }

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
    _formValues.remove(key);
    // Clear shared values based on which calculator is being cleared
    _clearSharedValuesForKey(key);
    notifyListeners();
  }

  void _clearSharedValuesForKey(String key) {
    switch (key) {
      case 'imc':
        _sharedPeso = '';
        _sharedAltura = '';
        break;
      case 'creatinine_clearance':
        _sharedIdade = '';
        _sharedPeso = '';
        break;
      case 'dose_peso':
        _sharedPeso = '';
        break;
    }
  }

  void clearAll() {
    _results.clear();
    _classifications.clear();
    _formValues.clear();
    _sharedPeso = '';
    _sharedAltura = '';
    _sharedIdade = '';
    notifyListeners();
  }

  bool hasResult(String key) => _results.containsKey(key) && _results[key] != null;
  
  bool get hasAnyResult => _results.values.any((v) => v != null);

  // Form values storage
  void setFormValues(String key, Map<String, dynamic> values) {
    _formValues[key] = Map.from(values);
  }

  Map<String, dynamic>? getFormValues(String key) => _formValues[key];

  void clearFormValues(String key) {
    _formValues.remove(key);
  }

  // Visible items management
  List<String>? _visibleItemKeys;
  
  List<String>? get visibleItemKeys => _visibleItemKeys;

  void setVisibleItemKeys(List<String> keys) {
    _visibleItemKeys = List.from(keys);
    notifyListeners();
  }

  void resetVisibleItems() {
    _visibleItemKeys = null;
    notifyListeners();
  }

  bool isItemVisible(String key) {
    if (_visibleItemKeys == null) return true; // Show all by default
    return _visibleItemKeys!.contains(key);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AXYN',
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalculosSection(),
    const PediatriaSection(),
    const SobreSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Cálculos',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Pediatria',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}

class CalculoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? page;
  final String? storeKey;
  final String? resultUnit;

  const CalculoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.page,
    this.storeKey,
    this.resultUnit,
  });
}

class CalculosSection extends StatefulWidget {
  const CalculosSection({super.key});

  @override
  State<CalculosSection> createState() => _CalculosSectionState();
}

class _CalculosSectionState extends State<CalculosSection> {
  final CalculationStore _store = CalculationStore();

  static final List<CalculoItem> _allItems = [
    const CalculoItem(
      title: 'Calculadora IMC',
      subtitle: 'Índice de Massa Corporal',
      icon: Icons.monitor_weight_outlined,
      page: ImcCalculatorScreen(),
      storeKey: 'imc',
      resultUnit: '',
    ),
    const CalculoItem(
      title: 'Clearance Creatinina',
      subtitle: 'Função Renal',
      icon: Icons.water_drop_outlined,
      page: CreatinineClearanceScreen(),
      storeKey: 'creatinine_clearance',
      resultUnit: 'mL/min',
    ),
    const CalculoItem(
      title: 'Dose por Peso',
      subtitle: 'Cálculo de Medicamentos',
      icon: Icons.medication_outlined,
      page: DosePorPesoScreen(),
      storeKey: 'dose_peso',
      resultUnit: '',
    ),
    const CalculoItem(
      title: 'Glasgow',
      subtitle: 'Escala de Coma',
      icon: Icons.psychology_outlined,
      page: GlasgowScreen(),
      storeKey: 'glasgow',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: 'CHA₂DS₂-VASc',
      subtitle: 'Risco de AVC',
      icon: Icons.favorite_outlined,
      page: Cha2ds2VascScreen(),
      storeKey: 'cha2ds2vasc',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: 'HAS-BLED',
      subtitle: 'Risco de Sangramento',
      icon: Icons.bloodtype_outlined,
      page: HasBledScreen(),
      storeKey: 'hasbled',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: 'Wells TEP',
      subtitle: 'Embolia Pulmonar',
      icon: Icons.air_outlined,
      page: WellsTepScreen(),
      storeKey: 'wells_tep',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: 'Correção Na⁺',
      subtitle: 'Sódio Corrigido',
      icon: Icons.science_outlined,
      page: SodiumCorrectionScreen(),
      storeKey: 'sodium_correction',
      resultUnit: 'mEq/L',
    ),
    const CalculoItem(
      title: 'Osmolaridade',
      subtitle: 'Osmolaridade Plasmática',
      icon: Icons.opacity_outlined,
      page: OsmolarityScreen(),
      storeKey: 'osmolarity',
      resultUnit: 'mOsm/L',
    ),
    const CalculoItem(
      title: 'Idade Gestacional',
      subtitle: 'IG e DPP',
      icon: Icons.pregnant_woman_outlined,
      page: GestationalAgeScreen(),
      storeKey: 'gestational_age',
      resultUnit: '',
    ),
  ];

  List<CalculoItem> get _visibleItems {
    if (_store.visibleItemKeys == null) return _allItems;
    return _allItems.where((item) => _store.isItemVisible(item.storeKey ?? '')).toList();
  }

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

  void _openEditMode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EditItemsSheet(
        allItems: _allItems,
        store: _store,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyResult = _store.hasAnyResult;
    final visibleItems = _visibleItems;
    
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
                  'Cálculos',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _openEditMode,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar calculadoras',
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
                itemCount: visibleItems.length,
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
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
      // Glasgow classifications
      case 'TCE Leve':
        return Colors.green;
      case 'TCE Moderado':
        return Colors.orange;
      case 'TCE Grave':
        return Colors.red;
      // CHA2DS2-VASc classifications
      case 'Baixo risco':
        return Colors.green;
      case 'Risco moderado':
        return Colors.orange;
      case 'Alto risco':
        return Colors.red;
      // HAS-BLED classifications
      case 'Baixo risco sangramento':
        return Colors.green;
      case 'Risco moderado sangramento':
        return Colors.orange;
      case 'Alto risco sangramento':
        return Colors.red;
      // Wells TEP classifications
      case 'Baixa probabilidade':
        return Colors.green;
      case 'Probabilidade moderada':
        return Colors.orange;
      case 'Alta probabilidade':
        return Colors.red;
      // Sodium/Osmolarity - general
      case 'Normal':
        return Colors.green;
      case 'Hiponatremia':
      case 'Hipo-osmolar':
        return Colors.orange;
      case 'Hipernatremia':
      case 'Hiperosmolar':
        return Colors.red;
      // Dose calculation
      case 'Calculado':
        return Colors.blue;
      // Gestational age
      case 'Idade Gestacional':
        return Colors.purple;
      default:
        return Colors.blue;
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

// Edit Items Bottom Sheet
class _EditItemsSheet extends StatefulWidget {
  final List<CalculoItem> allItems;
  final CalculationStore store;

  const _EditItemsSheet({
    required this.allItems,
    required this.store,
  });

  @override
  State<_EditItemsSheet> createState() => _EditItemsSheetState();
}

class _EditItemsSheetState extends State<_EditItemsSheet> {
  late List<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    // Initialize with current visible items or all items if none set
    if (widget.store.visibleItemKeys != null) {
      _selectedKeys = List.from(widget.store.visibleItemKeys!);
    } else {
      _selectedKeys = widget.allItems.map((item) => item.storeKey ?? '').where((key) => key.isNotEmpty).toList();
    }
  }

  void _toggleItem(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedKeys = widget.allItems.map((item) => item.storeKey ?? '').where((key) => key.isNotEmpty).toList();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedKeys.clear();
    });
  }

  void _save() {
    if (_selectedKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma calculadora'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Preserve original order
    final orderedKeys = widget.allItems
        .map((item) => item.storeKey ?? '')
        .where((key) => key.isNotEmpty && _selectedKeys.contains(key))
        .toList();
    widget.store.setVisibleItemKeys(orderedKeys);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculadoras atualizadas'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _reset() {
    widget.store.resetVisibleItems();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas as calculadoras restauradas'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Editar Calculadoras',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _selectAll,
                            child: const Text('Todas'),
                          ),
                          TextButton(
                            onPressed: _deselectAll,
                            child: const Text('Nenhuma'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione as calculadoras que deseja exibir.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.allItems.length,
                itemBuilder: (context, index) {
                  final item = widget.allItems[index];
                  final key = item.storeKey ?? '';
                  final isSelected = _selectedKeys.contains(key);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) => _toggleItem(key),
                    secondary: Icon(
                      item.icon,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.grey,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(
                        color: isSelected ? Colors.grey : Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Restaurar Padrão'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text('Salvar (${_selectedKeys.length})'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==================== Pediatria SECTION ====================
class PediatriaSection extends StatefulWidget {
  const PediatriaSection({super.key});

  @override
  State<PediatriaSection> createState() => _PediatriaSectionState();
}

class _PediatriaSectionState extends State<PediatriaSection> {
  double _peso = 10.0;
  final CalculationStore _store = CalculationStore();

  @override
  void initState() {
    super.initState();
    // Load shared weight if available
    if (_store.sharedPeso.isNotEmpty) {
      final parsedPeso = double.tryParse(_store.sharedPeso.replaceAll(',', '.'));
      if (parsedPeso != null && parsedPeso >= 1 && parsedPeso <= 200) {
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
          Padding(
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
                // Weight selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Peso',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_peso.toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          thumbColor: Theme.of(context).colorScheme.primary,
                          overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _peso,
                          min: 1,
                          max: 200,
                          divisions: 298,
                          onChanged: _onPesoChanged,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Text('200 kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Drug list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _DrugDosageCard(
                  name: 'Paracetamol',
                  icon: Icons.healing,
                  color: Colors.blue,
                  peso: _peso,
                  doseMin: 10,
                  doseMax: 15,
                  frequency: 'a cada 4–6 horas',
                  maxDaily: 75,
                  maxDoses: 4,
                  observation: 'Geralmente máx. 4 doses/dia',
                ),
                _DrugDosageCard(
                  name: 'Ibuprofeno',
                  icon: Icons.local_pharmacy,
                  color: Colors.orange,
                  peso: _peso,
                  doseMin: 5,
                  doseMax: 10,
                  frequency: 'a cada 6–8 horas',
                  maxDaily: 40,
                  maxDoses: 3,
                  observation: 'Uso apenas acima de 6 meses',
                  restriction: '> 6 meses',
                ),
                _DrugDosageCard(
                  name: 'Dipirona',
                  icon: Icons.medication_liquid,
                  color: Colors.purple,
                  peso: _peso,
                  doseMin: 10,
                  doseMax: 15,
                  frequency: 'a cada 6–8 horas',
                  maxDoses: 4,
                  observation: 'Respeitar protocolos institucionais',
                ),
                _DrugDosageCard(
                  name: 'Amoxicilina',
                  icon: Icons.vaccines,
                  color: Colors.green,
                  peso: _peso,
                  doseMin: 25,
                  doseMax: 50,
                  frequency: '2 a 3 tomadas por dia',
                  isDailyDose: true,
                  divisions: [2, 3],
                  observation: 'Duração típica: 7–10 dias',
                ),
                _DrugDosageCard(
                  name: 'Loratadina',
                  icon: Icons.air,
                  color: Colors.teal,
                  peso: _peso,
                  doseMin: 0.2,
                  doseMax: 0.2,
                  frequency: '1 vez ao dia',
                  isDailyDose: true,
                  observation: 'Indicação: rinite alérgica, urticária',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugDosageCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final double peso;
  final double doseMin;
  final double doseMax;
  final String frequency;
  final double? maxDaily;
  final int? maxDoses;
  final String? observation;
  final String? restriction;
  final bool isDailyDose;
  final List<int>? divisions;

  const _DrugDosageCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.peso,
    required this.doseMin,
    required this.doseMax,
    required this.frequency,
    this.maxDaily,
    this.maxDoses,
    this.observation,
    this.restriction,
    this.isDailyDose = false,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    final doseMinCalc = peso * doseMin;
    final doseMaxCalc = peso * doseMax;
    final maxDailyCalc = maxDaily != null ? peso * maxDaily! : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (restriction != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    restriction!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: isDailyDose ? 'Dose diária: ' : 'Dose: ',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: doseMin == doseMax
                          ? '${doseMinCalc.toStringAsFixed(1)} mg'
                          : '${doseMinCalc.toStringAsFixed(1)} – ${doseMaxCalc.toStringAsFixed(1)} mg',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'Dose padrão', '${doseMin}–${doseMax} mg/kg${isDailyDose ? '/dia' : '/dose'}'),
                  _buildInfoRow(context, 'Frequência', frequency),
                  if (maxDailyCalc != null)
                    _buildInfoRow(context, 'Dose máx. diária', '${maxDailyCalc.toStringAsFixed(1)} mg ($maxDaily mg/kg/dia)'),
                  if (maxDoses != null)
                    _buildInfoRow(context, 'Máx. doses/dia', '$maxDoses doses'),
                  if (divisions != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dose por tomada:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: divisions!.map((div) {
                        final dosePerTake = doseMaxCalc / div;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$div×/dia: ${dosePerTake.toStringAsFixed(1)} mg',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (observation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              observation!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
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
    // Load shared values first
    if (_store.sharedPeso.isNotEmpty) {
      _pesoController.text = _store.sharedPeso;
    }
    if (_store.sharedAltura.isNotEmpty) {
      _alturaController.text = _store.sharedAltura;
    }
    // Then load specific form values
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
    // Save to shared values
    _store.setSharedPeso(_pesoController.text);
    _store.setSharedAltura(_alturaController.text);
    // Save to form values
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

    // Save result and form values to store
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
    // Load shared values first
    if (_store.sharedIdade.isNotEmpty) {
      _idadeController.text = _store.sharedIdade;
    }
    if (_store.sharedPeso.isNotEmpty) {
      _pesoController.text = _store.sharedPeso;
    }
    // Then load specific form values
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
    // Save to shared values
    _store.setSharedIdade(_idadeController.text);
    _store.setSharedPeso(_pesoController.text);
    // Save to form values
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

    // Save result and form values to store
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
    // Load shared weight first
    if (_store.sharedPeso.isNotEmpty) {
      _pesoController.text = _store.sharedPeso;
    }
    // Then load specific form values
    final values = _store.getFormValues('dose_peso');
    if (values != null) {
      if (values['peso']?.isNotEmpty == true) _pesoController.text = values['peso'];
      _doseController.text = values['dose'] ?? '';
      _resultado = values['resultado'];
    }
  }

  void _saveFormValues() {
    // Save to shared values
    _store.setSharedPeso(_pesoController.text);
    // Save to form values
    _store.setFormValues('dose_peso', {'peso': _pesoController.text, 'dose': _doseController.text, 'resultado': _resultado});
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
    _saveFormValues();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.medication_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Cálculo de Dose', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _pesoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                hintText: 'Ex: 70',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Dose (mg/kg)',
                hintText: 'Ex: 10',
                prefixIcon: const Icon(Icons.science_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
            if (_resultado != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  children: [
                    Text('Dose Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${_resultado!.toStringAsFixed(1)} mg', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ],
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
  int _ocular = 0;
  int _verbal = 0;
  int _motor = 0;

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

  void _saveFormValues() {
    _store.setFormValues('glasgow', {'ocular': _ocular, 'verbal': _verbal, 'motor': _motor});
  }

  int get _total => _ocular + _verbal + _motor;

  String _getClassificacao(int score) {
    if (score >= 13) return 'TCE Leve';
    if (score >= 9) return 'TCE Moderado';
    return 'TCE Grave';
  }

  Color _getColor(int score) {
    if (score >= 13) return Colors.green;
    if (score >= 9) return Colors.orange;
    return Colors.red;
  }

  void _salvar() {
    if (_total > 0) {
      _store.setResult('glasgow', _total.toDouble(), classification: _getClassificacao(_total));
      _saveFormValues();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _limpar() {
    setState(() {
      _ocular = 0;
      _verbal = 0;
      _motor = 0;
    });
    _store.clearFormValues('glasgow');
    _store.clearResult('glasgow');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(_total);
    return Scaffold(
      appBar: AppBar(title: const Text('Escala de Glasgow'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_total > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color, width: 2),
                ),
                child: Column(
                  children: [
                    Text('$_total', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                    Text(_getClassificacao(_total), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildSection('Abertura Ocular', [
              _buildOption('Espontânea', 4, _ocular, (v) => setState(() => _ocular = v)),
              _buildOption('Ao estímulo verbal', 3, _ocular, (v) => setState(() => _ocular = v)),
              _buildOption('Ao estímulo doloroso', 2, _ocular, (v) => setState(() => _ocular = v)),
              _buildOption('Ausente', 1, _ocular, (v) => setState(() => _ocular = v)),
            ]),
            const SizedBox(height: 16),
            _buildSection('Resposta Verbal', [
              _buildOption('Orientada', 5, _verbal, (v) => setState(() => _verbal = v)),
              _buildOption('Confusa', 4, _verbal, (v) => setState(() => _verbal = v)),
              _buildOption('Palavras inapropriadas', 3, _verbal, (v) => setState(() => _verbal = v)),
              _buildOption('Sons incompreensíveis', 2, _verbal, (v) => setState(() => _verbal = v)),
              _buildOption('Ausente', 1, _verbal, (v) => setState(() => _verbal = v)),
            ]),
            const SizedBox(height: 16),
            _buildSection('Resposta Motora', [
              _buildOption('Obedece comandos', 6, _motor, (v) => setState(() => _motor = v)),
              _buildOption('Localiza dor', 5, _motor, (v) => setState(() => _motor = v)),
              _buildOption('Movimento de retirada', 4, _motor, (v) => setState(() => _motor = v)),
              _buildOption('Flexão anormal', 3, _motor, (v) => setState(() => _motor = v)),
              _buildOption('Extensão anormal', 2, _motor, (v) => setState(() => _motor = v)),
              _buildOption('Ausente', 1, _motor, (v) => setState(() => _motor = v)),
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _total > 0 ? _salvar : null, icon: const Icon(Icons.save), label: const Text('Salvar'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> options) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
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
            child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...options,
        ],
      ),
    );
  }

  Widget _buildOption(String label, int value, int groupValue, ValueChanged<int> onChanged) {
    return RadioListTile<int>(
      title: Text(label),
      secondary: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
      value: value,
      groupValue: groupValue,
      onChanged: (v) => onChanged(v!),
      dense: true,
    );
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
  bool _chf = false;
  bool _hypertension = false;
  bool _age75 = false;
  bool _diabetes = false;
  bool _stroke = false;
  bool _vascular = false;
  bool _age65 = false;
  bool _female = false;

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

  void _saveFormValues() {
    _store.setFormValues('cha2ds2vasc', {
      'chf': _chf, 'hypertension': _hypertension, 'age75': _age75, 'diabetes': _diabetes,
      'stroke': _stroke, 'vascular': _vascular, 'age65': _age65, 'female': _female,
    });
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

  String _getClassificacao(int score) {
    if (score == 0) return 'Baixo risco';
    if (score == 1) return 'Risco moderado';
    return 'Alto risco';
  }

  Color _getColor(int score) {
    if (score == 0) return Colors.green;
    if (score == 1) return Colors.orange;
    return Colors.red;
  }

  String _getRecomendacao(int score) {
    if (score == 0) return 'Anticoagulação não recomendada';
    if (score == 1) return 'Considerar anticoagulação';
    return 'Anticoagulação recomendada';
  }

  void _salvar() {
    _store.setResult('cha2ds2vasc', _score.toDouble(), classification: _getClassificacao(_score));
    _saveFormValues();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() {
      _chf = _hypertension = _age75 = _diabetes = _stroke = _vascular = _age65 = _female = false;
    });
    _store.clearFormValues('cha2ds2vasc');
    _store.clearResult('cha2ds2vasc');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(_score);
    return Scaffold(
      appBar: AppBar(title: const Text('CHA₂DS₂-VASc'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2)),
              child: Column(
                children: [
                  Text('$_score', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  Text(_getClassificacao(_score), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(_getRecomendacao(_score), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCheckItem('C - Insuficiência cardíaca', '+1', _chf, (v) => setState(() => _chf = v!)),
            _buildCheckItem('H - Hipertensão', '+1', _hypertension, (v) => setState(() => _hypertension = v!)),
            _buildCheckItem('A₂ - Idade ≥ 75 anos', '+2', _age75, (v) => setState(() => _age75 = v!)),
            _buildCheckItem('D - Diabetes mellitus', '+1', _diabetes, (v) => setState(() => _diabetes = v!)),
            _buildCheckItem('S₂ - AVC/AIT/Tromboembolismo', '+2', _stroke, (v) => setState(() => _stroke = v!)),
            _buildCheckItem('V - Doença vascular', '+1', _vascular, (v) => setState(() => _vascular = v!)),
            _buildCheckItem('A - Idade 65-74 anos', '+1', _age65, (v) => setState(() => _age65 = v!)),
            _buildCheckItem('Sc - Sexo feminino', '+1', _female, (v) => setState(() => _female = v!)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.save), label: const Text('Salvar'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, String points, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(title: Text(label), secondary: Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)), value: value, onChanged: onChanged);
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
  bool _hypertension = false;
  bool _renal = false;
  bool _liver = false;
  bool _stroke = false;
  bool _bleeding = false;
  bool _labile = false;
  bool _age = false;
  bool _drugs = false;
  bool _alcohol = false;

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

  void _saveFormValues() {
    _store.setFormValues('hasbled', {
      'hypertension': _hypertension, 'renal': _renal, 'liver': _liver, 'stroke': _stroke,
      'bleeding': _bleeding, 'labile': _labile, 'age': _age, 'drugs': _drugs, 'alcohol': _alcohol,
    });
  }

  int get _score {
    int s = 0;
    if (_hypertension) s++;
    if (_renal) s++;
    if (_liver) s++;
    if (_stroke) s++;
    if (_bleeding) s++;
    if (_labile) s++;
    if (_age) s++;
    if (_drugs) s++;
    if (_alcohol) s++;
    return s;
  }

  String _getClassificacao(int score) {
    if (score <= 1) return 'Baixo risco sangramento';
    if (score == 2) return 'Risco moderado sangramento';
    return 'Alto risco sangramento';
  }

  Color _getColor(int score) {
    if (score <= 1) return Colors.green;
    if (score == 2) return Colors.orange;
    return Colors.red;
  }

  void _salvar() {
    _store.setResult('hasbled', _score.toDouble(), classification: _getClassificacao(_score));
    _saveFormValues();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() {
      _hypertension = _renal = _liver = _stroke = _bleeding = _labile = _age = _drugs = _alcohol = false;
    });
    _store.clearFormValues('hasbled');
    _store.clearResult('hasbled');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(_score);
    return Scaffold(
      appBar: AppBar(title: const Text('HAS-BLED'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2)),
              child: Column(
                children: [
                  Text('$_score', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  Text(_getClassificacao(_score), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCheckItem('H - Hipertensão (PAS > 160)', _hypertension, (v) => setState(() => _hypertension = v!)),
            _buildCheckItem('A - Função renal anormal', _renal, (v) => setState(() => _renal = v!)),
            _buildCheckItem('A - Função hepática anormal', _liver, (v) => setState(() => _liver = v!)),
            _buildCheckItem('S - AVC prévio', _stroke, (v) => setState(() => _stroke = v!)),
            _buildCheckItem('B - Sangramento prévio', _bleeding, (v) => setState(() => _bleeding = v!)),
            _buildCheckItem('L - INR lábil', _labile, (v) => setState(() => _labile = v!)),
            _buildCheckItem('E - Idade > 65 anos', _age, (v) => setState(() => _age = v!)),
            _buildCheckItem('D - Uso de drogas (AINEs/antiplaq.)', _drugs, (v) => setState(() => _drugs = v!)),
            _buildCheckItem('D - Uso de álcool', _alcohol, (v) => setState(() => _alcohol = v!)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.save), label: const Text('Salvar'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(title: Text(label), value: value, onChanged: onChanged);
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
  bool _dvtSymptoms = false;
  bool _noAlternative = false;
  bool _hr100 = false;
  bool _immobilization = false;
  bool _previousDvtPe = false;
  bool _hemoptysis = false;
  bool _malignancy = false;

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

  void _saveFormValues() {
    _store.setFormValues('wells_tep', {
      'dvtSymptoms': _dvtSymptoms, 'noAlternative': _noAlternative, 'hr100': _hr100,
      'immobilization': _immobilization, 'previousDvtPe': _previousDvtPe, 'hemoptysis': _hemoptysis, 'malignancy': _malignancy,
    });
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

  String _getClassificacao(double score) {
    if (score <= 1) return 'Baixa probabilidade';
    if (score <= 6) return 'Probabilidade moderada';
    return 'Alta probabilidade';
  }

  Color _getColor(double score) {
    if (score <= 1) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getProbabilidade(double score) {
    if (score <= 1) return '~1.3% chance de TEP';
    if (score <= 6) return '~16.2% chance de TEP';
    return '~37.5% chance de TEP';
  }

  void _salvar() {
    _store.setResult('wells_tep', _score, classification: _getClassificacao(_score));
    _saveFormValues();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resultado salvo'), duration: Duration(seconds: 1)));
  }

  void _limpar() {
    setState(() {
      _dvtSymptoms = _noAlternative = _hr100 = _immobilization = _previousDvtPe = _hemoptysis = _malignancy = false;
    });
    _store.clearFormValues('wells_tep');
    _store.clearResult('wells_tep');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(_score);
    return Scaffold(
      appBar: AppBar(title: const Text('Wells - TEP'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2)),
              child: Column(
                children: [
                  Text(_score.toStringAsFixed(1), style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  Text(_getClassificacao(_score), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(_getProbabilidade(_score), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCheckItem('Sinais/sintomas clínicos de TVP', '+3', _dvtSymptoms, (v) => setState(() => _dvtSymptoms = v!)),
            _buildCheckItem('TEP é o diagnóstico mais provável', '+3', _noAlternative, (v) => setState(() => _noAlternative = v!)),
            _buildCheckItem('FC > 100 bpm', '+1.5', _hr100, (v) => setState(() => _hr100 = v!)),
            _buildCheckItem('Imobilização/cirurgia nas últimas 4 sem', '+1.5', _immobilization, (v) => setState(() => _immobilization = v!)),
            _buildCheckItem('TVP/TEP prévios', '+1.5', _previousDvtPe, (v) => setState(() => _previousDvtPe = v!)),
            _buildCheckItem('Hemoptise', '+1', _hemoptysis, (v) => setState(() => _hemoptysis = v!)),
            _buildCheckItem('Malignidade', '+1', _malignancy, (v) => setState(() => _malignancy = v!)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.save), label: const Text('Salvar'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, String points, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(title: Text(label), secondary: Text(points, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)), value: value, onChanged: onChanged);
  }
}

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

  void _saveFormValues() {
    _store.setFormValues('sodium_correction', {
      'sodium': _sodiumController.text, 'glucose': _glucoseController.text, 'correctedSodium': _correctedSodium,
    });
  }

  void _calcular() {
    final sodium = double.tryParse(_sodiumController.text.replaceAll(',', '.'));
    final glucose = double.tryParse(_glucoseController.text.replaceAll(',', '.'));

    if (sodium == null || glucose == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira valores válidos'), backgroundColor: Colors.red));
      return;
    }

    // Fórmula: Na corrigido = Na medido + 1.6 × ((Glicose - 100) / 100)
    final corrected = sodium + 1.6 * ((glucose - 100) / 100);
    final classification = corrected < 135 ? 'Hiponatremia' : (corrected > 145 ? 'Hipernatremia' : 'Normal');

    setState(() => _correctedSodium = corrected);
    _store.setResult('sodium_correction', corrected, classification: classification);
    _saveFormValues();
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

  Color _getColor(double sodium) {
    if (sodium < 135) return Colors.orange;
    if (sodium > 145) return Colors.red;
    return Colors.green;
  }

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
            TextField(
              controller: _sodiumController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Sódio medido (mEq/L)', hintText: 'Ex: 130', prefixIcon: const Icon(Icons.water_drop_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _glucoseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Glicemia (mg/dL)', hintText: 'Ex: 400', prefixIcon: const Icon(Icons.bloodtype_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _calcular, icon: const Icon(Icons.calculate), label: const Text('Calcular'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
            if (_correctedSodium != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: _getColor(_correctedSodium!).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: _getColor(_correctedSodium!), width: 2)),
                child: Column(
                  children: [
                    Text('Sódio Corrigido', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${_correctedSodium!.toStringAsFixed(1)} mEq/L', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: _getColor(_correctedSodium!))),
                    const SizedBox(height: 8),
                    Text(_correctedSodium! < 135 ? 'Hiponatremia' : (_correctedSodium! > 145 ? 'Hipernatremia' : 'Normal'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _getColor(_correctedSodium!), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
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

  void _saveFormValues() {
    _store.setFormValues('osmolarity', {
      'sodium': _sodiumController.text, 'glucose': _glucoseController.text, 'urea': _ureaController.text, 'osmolarity': _osmolarity,
    });
  }

  void _calcular() {
    final sodium = double.tryParse(_sodiumController.text.replaceAll(',', '.'));
    final glucose = double.tryParse(_glucoseController.text.replaceAll(',', '.'));
    final urea = double.tryParse(_ureaController.text.replaceAll(',', '.'));

    if (sodium == null || glucose == null || urea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira valores válidos'), backgroundColor: Colors.red));
      return;
    }

    // Fórmula: Osm = 2×Na + (Glicose/18) + (Ureia/6)
    final osm = (2 * sodium) + (glucose / 18) + (urea / 6);
    final classification = osm < 280 ? 'Hipo-osmolar' : (osm > 295 ? 'Hiperosmolar' : 'Normal');

    setState(() => _osmolarity = osm);
    _store.setResult('osmolarity', osm, classification: classification);
    _saveFormValues();
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

  Color _getColor(double osm) {
    if (osm < 280) return Colors.orange;
    if (osm > 295) return Colors.red;
    return Colors.green;
  }

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
            TextField(
              controller: _sodiumController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Sódio (mEq/L)', hintText: 'Ex: 140', prefixIcon: const Icon(Icons.water_drop_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _glucoseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Glicemia (mg/dL)', hintText: 'Ex: 100', prefixIcon: const Icon(Icons.bloodtype_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ureaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Ureia (mg/dL)', hintText: 'Ex: 40', prefixIcon: const Icon(Icons.science_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: _calcular, icon: const Icon(Icons.calculate), label: const Text('Calcular'))),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _limpar, icon: const Icon(Icons.refresh), label: const Text('Limpar')),
              ],
            ),
            if (_osmolarity != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: _getColor(_osmolarity!).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: _getColor(_osmolarity!), width: 2)),
                child: Column(
                  children: [
                    Text('Osmolaridade', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${_osmolarity!.toStringAsFixed(1)} mOsm/L', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: _getColor(_osmolarity!))),
                    const SizedBox(height: 8),
                    Text(_osmolarity! < 280 ? 'Hipo-osmolar' : (_osmolarity! > 295 ? 'Hiperosmolar' : 'Normal'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _getColor(_osmolarity!), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Normal: 280-295 mOsm/L', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
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

  void _saveFormValues() {
    _store.setFormValues('gestational_age', {
      'dum': _dum?.toIso8601String(),
    });
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dum ?? DateTime.now().subtract(const Duration(days: 60)),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
      helpText: 'Selecione a DUM',
    );
    if (picked != null) {
      _calcular(picked);
    }
  }

  void _calcular(DateTime dum) {
    final now = DateTime.now();
    final diff = now.difference(dum).inDays;
    final semanas = diff ~/ 7;
    final dias = diff % 7;
    final dpp = dum.add(const Duration(days: 280)); // 40 semanas

    setState(() {
      _dum = dum;
      _semanas = semanas;
      _dias = dias;
      _dpp = dpp;
    });

    _store.setResult('gestational_age', semanas.toDouble(), classification: 'Idade Gestacional');
    _saveFormValues();
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

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getTrimestre(int semanas) {
    if (semanas < 14) return '1º Trimestre';
    if (semanas < 28) return '2º Trimestre';
    return '3º Trimestre';
  }

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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple, width: 2)),
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
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pink, width: 2)),
                child: Column(
                  children: [
                    Text('Data Provável do Parto', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(_formatDate(_dpp!), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.pink)),
                    const SizedBox(height: 8),
                    Text('(40 semanas)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    if (_semanas == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
            child: Text('Informações', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          _buildInfoRow('DUM', _formatDate(_dum!)),
          _buildInfoRow('Dias de gestação', '${_semanas! * 7 + _dias!} dias'),
          _buildInfoRow('Semanas completas', '$_semanas semanas'),
          _buildInfoRow('Trimestre', _getTrimestre(_semanas!), isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
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

// ==================== SOBRE SECTION ====================
class SobreSection extends StatelessWidget {
  const SobreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // App Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AXYN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versão 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calculadoras médicas e dosagens pediátricas para profissionais de saúde',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Terms and Legal
            _buildSectionCard(
              context,
              title: 'Termos de Uso',
              icon: Icons.description_outlined,
              content: '''
Ao utilizar o aplicativo AXYN, você concorda com os seguintes termos:

1. FINALIDADE DO APLICATIVO
Este aplicativo é uma ferramenta de apoio e referência para profissionais de saúde. Os cálculos e dosagens apresentados são baseados em diretrizes e literatura médica estabelecidas.

2. ISENÇÃO DE RESPONSABILIDADE MÉDICA
• As informações fornecidas NÃO substituem o julgamento clínico profissional
• Todas as decisões médicas devem ser tomadas por profissionais qualificados
• O desenvolvedor não se responsabiliza por decisões clínicas baseadas exclusivamente neste aplicativo
• Sempre verifique as informações com fontes primárias e protocolos institucionais

3. USO ADEQUADO
• Este aplicativo destina-se exclusivamente a profissionais de saúde e estudantes da área
• Os resultados devem ser sempre validados antes de qualquer aplicação clínica
• O usuário assume total responsabilidade pelo uso das informações

4. PRECISÃO DAS INFORMAÇÕES
• Embora nos esforcemos para manter as informações atualizadas e precisas, não garantimos que estejam livres de erros
• As dosagens podem variar conforme protocolos institucionais e condições específicas do paciente

5. ATUALIZAÇÕES
Reservamo-nos o direito de atualizar estes termos a qualquer momento. O uso continuado do aplicativo após alterações constitui aceitação dos novos termos.
''',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Política de Privacidade',
              icon: Icons.privacy_tip_outlined,
              content: '''
1. COLETA DE DADOS
• Este aplicativo NÃO coleta dados pessoais
• Nenhuma informação é enviada para servidores externos
• Todos os dados são armazenados localmente no dispositivo

2. ARMAZENAMENTO LOCAL
• Os valores inseridos nas calculadoras são armazenados apenas localmente para conveniência do usuário
• Você pode limpar esses dados a qualquer momento através do próprio aplicativo

3. COMPARTILHAMENTO
• Não compartilhamos nenhuma informação com terceiros
• Não utilizamos serviços de análise ou rastreamento

4. SEGURANÇA
• Os dados permanecem exclusivamente em seu dispositivo
• Recomendamos manter seu dispositivo protegido com senha/biometria

5. CONTATO
Para dúvidas sobre privacidade, entre em contato através da página do aplicativo na loja.
''',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Aviso Legal',
              icon: Icons.gavel_outlined,
              content: '''
IMPORTANTE - LEIA COM ATENÇÃO:

Este aplicativo é fornecido "como está", sem garantias de qualquer tipo, expressas ou implícitas.

O AXYN é uma ferramenta de APOIO e CONSULTA RÁPIDA. Não deve ser utilizado como única fonte de informação para decisões clínicas.

RESPONSABILIDADES DO USUÁRIO:
• Verificar todas as dosagens com bulas e protocolos oficiais
• Considerar as condições individuais de cada paciente
• Consultar especialistas quando necessário
• Manter-se atualizado com as diretrizes vigentes

O desenvolvedor não assume responsabilidade por:
• Erros de interpretação das informações
• Uso inadequado do aplicativo
• Danos diretos ou indiretos resultantes do uso
• Decisões clínicas tomadas com base no aplicativo

Ao usar este aplicativo, você reconhece que leu, entendeu e concorda com todos os termos acima.
''',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Referências',
              icon: Icons.menu_book_outlined,
              content: '''
As fórmulas e dosagens utilizadas neste aplicativo são baseadas em:

• Diretrizes da Sociedade Brasileira de Pediatria (SBP)
• Protocolos do Ministério da Saúde
• Literatura médica estabelecida
• Consensos de especialidades médicas

As doses pediátricas seguem as recomendações padronizadas para uso ambulatorial, devendo ser ajustadas conforme necessidade clínica individual.

Última atualização das referências: Janeiro 2026
''',
            ),
            const SizedBox(height: 24),
            // Developer Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.code,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desenvolvido com ❤️ para profissionais de saúde',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 AXYN. Todos os direitos reservados.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    content.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
