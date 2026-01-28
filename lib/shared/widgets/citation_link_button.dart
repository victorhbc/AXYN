import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/sobre/data/medical_citations.dart';

/// Button to view citations for a specific calculator
class CitationLinkButton extends StatelessWidget {
  final String calculatorName;
  final bool isCompact;

  const CitationLinkButton({
    super.key,
    required this.calculatorName,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final citations = MedicalCitations.getCitationsForCalculator(calculatorName);
    
    if (citations.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      return InkWell(
        onTap: () => _showCitationsDialog(context, citations),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Ver citações',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showCitationsDialog(context, citations),
      icon: const Icon(Icons.menu_book_outlined),
      label: const Text('Ver Citações e Referências'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _showCitationsDialog(
    BuildContext context,
    List<CitationEntry> citations,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.menu_book_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Citações e Referências'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'As informações e cálculos deste escore são baseados nas seguintes referências científicas:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...citations.map((citation) => _buildCitationItem(context, citation)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationItem(BuildContext context, CitationEntry citation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              citation.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              citation.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${citation.authors}. ${citation.journal} ${citation.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (citation.doi != null) ...[
              const SizedBox(height: 4),
              Text(
                'DOI: ${citation.doi}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
            if (citation.url != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchUrl(citation.url!),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Abrir fonte original',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
