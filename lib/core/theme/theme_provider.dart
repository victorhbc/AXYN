import 'package:flutter/material.dart';

/// Provider for managing theme mode (light/dark)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

/// InheritedWidget to provide ThemeProvider to the widget tree
class ThemeProviderInherited extends InheritedWidget {
  final ThemeProvider provider;

  const ThemeProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<ThemeProviderInherited>();
    if (inherited == null) {
      throw StateError('ThemeProviderInherited not found in widget tree');
    }
    return inherited.provider;
  }

  @override
  bool updateShouldNotify(ThemeProviderInherited oldWidget) {
    return provider != oldWidget.provider;
  }
}
