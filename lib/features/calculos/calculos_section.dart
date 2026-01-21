import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../data/data.dart';
import 'screens/screens.dart';
import 'widgets/calculator_grid_item.dart';
import 'widgets/edit_items_sheet.dart';

/// Main section displaying all calculators in a grid
class CalculosSection extends StatefulWidget {
  const CalculosSection({super.key});

  @override
  State<CalculosSection> createState() => _CalculosSectionState();
}

class _CalculosSectionState extends State<CalculosSection> {
  final CalculationStore _store = CalculationStore();

  static final List<CalculoItem> _allItems = [
    const CalculoItem(
      title: AppStrings.imcTitle,
      subtitle: AppStrings.imcSubtitle,
      icon: Icons.monitor_weight_outlined,
      page: ImcCalculatorScreen(),
      storeKey: 'imc',
      resultUnit: '',
    ),
    const CalculoItem(
      title: AppStrings.clearanceTitle,
      subtitle: AppStrings.clearanceSubtitle,
      icon: Icons.water_drop_outlined,
      page: CreatinineClearanceScreen(),
      storeKey: 'creatinine_clearance',
      resultUnit: 'mL/min',
    ),
    const CalculoItem(
      title: AppStrings.dosePesoTitle,
      subtitle: AppStrings.dosePesoSubtitle,
      icon: Icons.medication_outlined,
      page: DosePorPesoScreen(),
      storeKey: 'dose_peso',
      resultUnit: '',
    ),
    const CalculoItem(
      title: AppStrings.glasgowTitle,
      subtitle: AppStrings.glasgowSubtitle,
      icon: Icons.psychology_outlined,
      page: GlasgowScreen(),
      storeKey: 'glasgow',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: AppStrings.cha2ds2Title,
      subtitle: AppStrings.cha2ds2Subtitle,
      icon: Icons.favorite_outlined,
      page: Cha2ds2VascScreen(),
      storeKey: 'cha2ds2vasc',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: AppStrings.hasBledTitle,
      subtitle: AppStrings.hasBledSubtitle,
      icon: Icons.bloodtype_outlined,
      page: HasBledScreen(),
      storeKey: 'hasbled',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: AppStrings.wellsTitle,
      subtitle: AppStrings.wellsSubtitle,
      icon: Icons.air_outlined,
      page: WellsTepScreen(),
      storeKey: 'wells_tep',
      resultUnit: 'pts',
    ),
    const CalculoItem(
      title: AppStrings.sodiumTitle,
      subtitle: AppStrings.sodiumSubtitle,
      icon: Icons.science_outlined,
      page: SodiumCorrectionScreen(),
      storeKey: 'sodium_correction',
      resultUnit: 'mEq/L',
    ),
    const CalculoItem(
      title: AppStrings.osmolarityTitle,
      subtitle: AppStrings.osmolaritySubtitle,
      icon: Icons.opacity_outlined,
      page: OsmolarityScreen(),
      storeKey: 'osmolarity',
      resultUnit: 'mOsm/L',
    ),
    const CalculoItem(
      title: AppStrings.gestationalTitle,
      subtitle: AppStrings.gestationalSubtitle,
      icon: Icons.pregnant_woman_outlined,
      page: GestationalAgeScreen(),
      storeKey: 'gestational_age',
      resultUnit: '',
    ),
  ];

  List<CalculoItem> get _visibleItems {
    if (_store.visibleItemKeys == null) return _allItems;
    return _allItems
        .where((item) => _store.isItemVisible(item.storeKey ?? ''))
        .toList();
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
      builder: (context) => EditItemsSheet(
        allItems: _allItems,
        store: _store,
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.limparTudo),
        content: const Text('Deseja limpar todos os resultados salvos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelar),
          ),
          FilledButton(
            onPressed: () {
              _store.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.todosResultadosLimpos),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(AppStrings.limpar),
          ),
        ],
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
            _buildHeader(hasAnyResult),
            const SizedBox(height: 16),
            Expanded(
              child: _buildGrid(visibleItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasAnyResult) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.calculosTab,
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
                onPressed: _showClearAllDialog,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text(AppStrings.limparTudo),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid(List<CalculoItem> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final hasResult =
            item.storeKey != null && _store.hasResult(item.storeKey!);
        final result =
            item.storeKey != null ? _store.getResult(item.storeKey!) : null;
        final classification = item.storeKey != null
            ? _store.getClassification(item.storeKey!)
            : null;

        return CalculatorGridItem(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          result: result,
          resultUnit: item.resultUnit,
          classification: classification,
          hasResult: hasResult,
          onTap: () => _navigateToCalculator(item),
          onClear: hasResult && item.storeKey != null
              ? () => _clearResult(item.storeKey!)
              : null,
        );
      },
    );
  }

  void _navigateToCalculator(CalculoItem item) {
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
  }

  void _clearResult(String storeKey) {
    _store.clearResult(storeKey);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.resultadoLimpo),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
