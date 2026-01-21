import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'data/legal_content.dart';
import 'widgets/app_info_card.dart';
import 'widgets/expandable_section_card.dart';

/// About section with app info and legal content
class SobreSection extends StatelessWidget {
  const SobreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 24),
            const AppInfoCard(),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            _buildFooter(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      AppStrings.sobreTab,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.copyright,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
