import 'package:flutter/foundation.dart';

import '../../core/constants/store_keys.dart';

/// Singleton store for calculation results and form values
class CalculationStore extends ChangeNotifier {
  static final CalculationStore _instance = CalculationStore._internal();
  factory CalculationStore() => _instance;
  CalculationStore._internal();

  final Map<String, double?> _results = {};
  final Map<String, String?> _classifications = {};
  final Map<String, Map<String, dynamic>> _formValues = {};
  List<String>? _visibleItemKeys;

  // Shared patient data across calculators
  String _sharedPeso = '';
  String _sharedAltura = '';
  String _sharedIdade = '';

  // Getters for shared values
  String get sharedPeso => _sharedPeso;
  String get sharedAltura => _sharedAltura;
  String get sharedIdade => _sharedIdade;

  // Getters for state
  List<String>? get visibleItemKeys => _visibleItemKeys;
  bool get hasAnyResult => _results.values.any((v) => v != null);

  // Shared value setters
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

  // Results management
  double? getResult(String key) => _results[key];
  String? getClassification(String key) => _classifications[key];
  bool hasResult(String key) =>
      _results.containsKey(key) && _results[key] != null;

  void setResult(String key, double value, {String? classification}) {
    _results[key] = value;
    _classifications[key] = classification;
    notifyListeners();
  }

  void clearResult(String key) {
    _results.remove(key);
    _classifications.remove(key);
    _formValues.remove(key);
    _clearSharedValuesForKey(key);
    notifyListeners();
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

  void _clearSharedValuesForKey(String key) {
    switch (key) {
      case StoreKeys.imc:
        _sharedPeso = '';
        _sharedAltura = '';
        break;
      case StoreKeys.creatinineClearance:
        _sharedIdade = '';
        _sharedPeso = '';
        break;
      // case StoreKeys.dosePeso:
      //   _sharedPeso = '';
      //   break;
    }
  }

  // Form values management
  void setFormValues(String key, Map<String, dynamic> values) {
    _formValues[key] = Map.from(values);
  }

  Map<String, dynamic>? getFormValues(String key) => _formValues[key];

  void clearFormValues(String key) {
    _formValues.remove(key);
  }

  // Visible items management
  void setVisibleItemKeys(List<String> keys) {
    _visibleItemKeys = List.from(keys);
    notifyListeners();
  }

  void resetVisibleItems() {
    _visibleItemKeys = null;
    notifyListeners();
  }

  bool isItemVisible(String key) {
    if (_visibleItemKeys == null) return true;
    return _visibleItemKeys!.contains(key);
  }
}
