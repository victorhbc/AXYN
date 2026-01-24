import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_provider.dart';
import '../sobre/data/legal_content.dart';
import '../sobre/widgets/app_info_card.dart';
import '../sobre/widgets/expandable_section_card.dart';

/// Settings section with app info, dark mode toggle, and legal content
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProviderInherited.of(context);
    
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTitle(context),
              const SizedBox(height: 24),
              const AppInfoCard(),
              const SizedBox(height: 24),
              _buildDarkModeToggle(context, themeProvider),
              const SizedBox(height: 24),
              _buildAboutSection(context),
              const SizedBox(height: 24),
              _buildFooter(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      AppStrings.settingsTab,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      child: SwitchListTile(
        title: const Text('Modo Escuro'),
        subtitle: const Text('Ativar tema escuro'),
        secondary: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const ExpandableSectionCard(
          title: 'Termos de Uso',
          icon: Icons.description_outlined,
          content: LegalContent.termsOfUse,
        ),
        const SizedBox(height: 16),
        const ExpandableSectionCard(
          title: 'Política de Privacidade',
          icon: Icons.privacy_tip_outlined,
          content: LegalContent.privacyPolicy,
        ),
        const SizedBox(height: 16),
        const ExpandableSectionCard(
          title: 'Aviso Legal',
          icon: Icons.gavel_outlined,
          content: LegalContent.legalNotice,
        ),
        const SizedBox(height: 16),
        const ExpandableSectionCard(
          title: 'Referências',
          icon: Icons.menu_book_outlined,
          content: LegalContent.references,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
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
            AppStrings.developerMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.copyright,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
