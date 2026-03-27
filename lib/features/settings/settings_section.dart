import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_provider.dart';
import '../sobre/data/legal_content.dart';
import '../sobre/widgets/app_info_card.dart';
import '../sobre/widgets/expandable_section_card.dart';

/// Settings section with app info, dark mode toggle, and legal content
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  static final Uri _supportPageUri = Uri.parse(
    'https://axyshealth.web.app/suporte',
  );

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
              // Temporarily commented for App Store guideline 1.4.1
              // const SizedBox(height: 24),
              // _buildMedicalDisclaimerCard(context),
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

  // Temporarily commented for App Store guideline 1.4.1
  // Widget _buildMedicalDisclaimerCard(BuildContext context) {
  //   return Card(
  //     color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
  //     child: ListTile(
  //       leading: Icon(
  //         Icons.warning_amber_rounded,
  //         color: Theme.of(context).colorScheme.error,
  //         size: 32,
  //       ),
  //       title: const Text(
  //         'Aviso Médico',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       subtitle: const Text(
  //         'Leia o aviso médico importante sobre o uso deste aplicativo',
  //       ),
  //       trailing: const Icon(Icons.chevron_right),
  //       onTap: () {
  //         MedicalDisclaimerDialog.show(context);
  //       },
  //     ),
  //   );
  // }

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
        _buildSupportSection(context),
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
        // Temporarily commented for App Store guideline 1.4.1 - medical citations
        // const CitationsSectionCard(),
        const SizedBox(height: 16),
        const ExpandableSectionCard(
          title: 'Referências Gerais',
          icon: Icons.info_outline,
          content: LegalContent.references,
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.support_agent_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Suporte',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                    'Precisa de ajuda? Acesse a página de suporte para entrar em contato por e-mail.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openSupportPageInBrowser,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir página de suporte'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSupportPageInBrowser() async {
    if (await canLaunchUrl(_supportPageUri)) {
      await launchUrl(_supportPageUri, webOnlyWindowName: '_self');
    }
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
