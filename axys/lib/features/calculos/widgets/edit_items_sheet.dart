import 'package:flutter/material.dart';

import '../../../data/data.dart';

/// Bottom sheet for editing visible calculators
class EditItemsSheet extends StatefulWidget {
  final List<CalculoItem> allItems;
  final CalculationStore store;

  const EditItemsSheet({
    super.key,
    required this.allItems,
    required this.store,
  });

  @override
  State<EditItemsSheet> createState() => _EditItemsSheetState();
}

class _EditItemsSheetState extends State<EditItemsSheet> {
  late List<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _initializeSelectedKeys();
  }

  void _initializeSelectedKeys() {
    if (widget.store.visibleItemKeys != null) {
      _selectedKeys = List.from(widget.store.visibleItemKeys!);
    } else {
      _selectedKeys = widget.allItems
          .map((item) => item.storeKey ?? '')
          .where((key) => key.isNotEmpty)
          .toList();
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
      _selectedKeys = widget.allItems
          .map((item) => item.storeKey ?? '')
          .where((key) => key.isNotEmpty)
          .toList();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedKeys.clear();
    });
  }

  void _save() {
    if (_selectedKeys.isEmpty) {
      _showError('Selecione pelo menos uma calculadora');
      return;
    }

    final orderedKeys = widget.allItems
        .map((item) => item.storeKey ?? '')
        .where((key) => key.isNotEmpty && _selectedKeys.contains(key))
        .toList();

    widget.store.setVisibleItemKeys(orderedKeys);
    Navigator.pop(context);
    _showSuccess('Calculadoras atualizadas');
  }

  void _reset() {
    widget.store.resetVisibleItems();
    Navigator.pop(context);
    _showSuccess('Todas as calculadoras restauradas');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
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
            _buildHeader(context),
            Expanded(child: _buildList(scrollController)),
            _buildFooter(context),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildList(ScrollController scrollController) {
    return ListView.builder(
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
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
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
    );
  }
}
