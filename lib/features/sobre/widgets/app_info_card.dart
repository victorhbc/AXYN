import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Card displaying app information
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildIcon(),
          const SizedBox(height: 16),
          _buildAppName(context),
          const SizedBox(height: 4),
          _buildVersion(context),
          const SizedBox(height: 16),
          _buildDescription(context),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
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
    );
  }

  Widget _buildAppName(BuildContext context) {
    return Text(
      AppStrings.appName,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }

  Widget _buildVersion(BuildContext context) {
    return Text(
      'Versão ${AppStrings.appVersion}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      AppStrings.appDescription,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
      textAlign: TextAlign.center,
    );
  }
}
