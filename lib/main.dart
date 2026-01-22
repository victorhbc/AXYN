import 'package:flutter/material.dart';

import 'core/core.dart';
import 'features/calculos/calculos_section.dart';
import 'features/pediatria/pediatria_section.dart';
import 'features/sobre/sobre_section.dart';
import 'shared/shared.dart';

void main() {
  runApp(const MainApp());
}

/// Main application widget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

/// Main screen with responsive navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    CalculosSection(),
    PediatriaSection(),
    SobreSection(),
  ];

  static const List<NavigationItem> _destinations = [
    NavigationItem(
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
      label: AppStrings.calculosTab,
    ),
    NavigationItem(
      icon: Icons.medication_outlined,
      selectedIcon: Icons.medication,
      label: AppStrings.pediatriaTab,
    ),
    NavigationItem(
      icon: Icons.info_outline,
      selectedIcon: Icons.info,
      label: AppStrings.sobreTab,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      pages: _pages,
      destinations: _destinations,
    );
  }
}
