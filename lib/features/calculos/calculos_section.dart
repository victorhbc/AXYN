import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../data/data.dart';
import '../../shared/shared.dart';
import 'screens/screens.dart';
import 'widgets/calculator_grid_item.dart';
import 'widgets/edit_items_sheet.dart';

/// Breakpoint for split-screen layout
const double _kSplitScreenBreakpoint = 900;

/// Main section displaying all calculators in a grid
class CalculosSection extends StatefulWidget {
  const CalculosSection({super.key});

  @override
  State<CalculosSection> createState() => _CalculosSectionState();
}

class _CalculosSectionState extends State<CalculosSection> {
  final CalculationStore _store = CalculationStore();
  CalculoItem? _selectedItem;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= _kSplitScreenBreakpoint;

        if (isWideScreen) {
          return _buildSplitLayout();
        } else {
          return _buildSingleLayout();
        }
      },
    );
  }

  /// Single column layout for narrow screens (mobile)
  Widget _buildSingleLayout() {
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
              child: _buildGrid(visibleItems, isSplitView: false),
            ),
          ],
        ),
      ),
    );
  }

  /// Split layout for wide screens (web/desktop)
  Widget _buildSplitLayout() {
    final hasAnyResult = _store.hasAnyResult;
    final visibleItems = _visibleItems;

    return SafeArea(
      child: Row(
        children: [
          // Left panel - Calculator list
          SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(hasAnyResult),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildGrid(visibleItems, isSplitView: true),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          const VerticalDivider(width: 1, thickness: 1),
          // Right panel - Selected calculator or placeholder
          Expanded(
            child: _selectedItem?.page != null
                ? _buildDetailPanel(_selectedItem!)
                : _buildPlaceholder(),
          ),
        ],
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
              IconButton(
                onPressed: _showClearAllDialog,
                icon: const Icon(Icons.delete_outline),
                tooltip: AppStrings.limparTudo,
                color: Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrid(List<CalculoItem> items, {required bool isSplitView}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSplitView ? 2 : _calculateCrossAxisCount(context),
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
        final isSelected = isSplitView && _selectedItem?.storeKey == item.storeKey;

        return CalculatorGridItem(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          result: result,
          resultUnit: item.resultUnit,
          classification: classification,
          hasResult: hasResult,
          isSelected: isSelected,
          onTap: () => _onItemTap(item, isSplitView),
          onClear: hasResult && item.storeKey != null
              ? () => _clearResult(item.storeKey!)
              : null,
        );
      },
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 800) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  void _onItemTap(CalculoItem item, bool isSplitView) {
    if (item.page == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} - Em breve'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (isSplitView) {
      // In split view, show in the right panel
      setState(() {
        _selectedItem = item;
      });
    } else {
      // In single view, navigate to new page using root navigator
      // This hides the bottom navigation bar
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => item.page!),
      );
    }
  }

  Widget _buildDetailPanel(CalculoItem item) {
    return ClipRect(
      child: Navigator(
        key: ValueKey(item.storeKey),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => item.page!,
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione uma calculadora',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um item da lista à esquerda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
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
