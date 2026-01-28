import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calculos/calculos_section.dart';
import '../../features/pediatria/pediatria_section.dart';
import '../../features/settings/settings_section.dart';
import '../../shared/shared.dart';
import '../constants/app_strings.dart';
import '../services/disclaimer_service.dart';

/// Route paths for the application
class AppRoutes {
  static const String calculadoras = '/calculadoras';
  static const String pediatria = '/pediatria';
  static const String settings = '/configuracoes';
}

/// Router configuration for the application
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.calculadoras,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.calculadoras,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalculosSection(),
            ),
          ),
          GoRoute(
            path: AppRoutes.pediatria,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PediatriaSection(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsSection(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Redirect root to calculadoras (default)
      if (state.uri.path == '/') {
        return AppRoutes.calculadoras;
      }
      // Redirect old sobre route to settings
      if (state.uri.path == '/sobre') {
        return AppRoutes.settings;
      }
      return null;
    },
    // Only update URL on web
    debugLogDiagnostics: kDebugMode,
  );

  /// Get the current index based on the route path
  static int getIndexFromPath(String path) {
    switch (path) {
      case AppRoutes.calculadoras:
        return 0;
      case AppRoutes.pediatria:
        return 1;
      case AppRoutes.settings:
        return 2;
      default:
        return 0;
    }
  }

  /// Get the route path based on the index
  static String getPathFromIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.calculadoras;
      case 1:
        return AppRoutes.pediatria;
      case 2:
        return AppRoutes.settings;
      default:
        return AppRoutes.calculadoras;
    }
  }
}

/// Main shell widget that provides navigation structure
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
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
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: AppStrings.settingsTab,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Check and show disclaimer on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDisclaimer();
    });
  }

  Future<void> _checkAndShowDisclaimer() async {
    final hasSeen = await DisclaimerService.hasSeenDisclaimer();
    if (!hasSeen && mounted) {
      await MedicalDisclaimerDialog.show(context, isFirstLaunch: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final currentIndex = AppRouter.getIndexFromPath(currentPath);

    return _ResponsiveNavigationShell(
      currentIndex: currentIndex,
      onDestinationSelected: (index) {
        context.go(AppRouter.getPathFromIndex(index));
      },
      destinations: _destinations,
      child: widget.child,
    );
  }
}

/// Responsive navigation shell with NavigationRail/BottomNav
class _ResponsiveNavigationShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> destinations;
  final Widget child;

  const _ResponsiveNavigationShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= Breakpoints.mobile;

        if (isWideScreen) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(
                Icons.medical_services_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            destinations: destinations
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
