import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/medical_citations.dart';

/// Expandable card displaying medical citations with clickable links
class CitationsSectionCard extends StatelessWidget {
  const CitationsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Citações e Referências Médicas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            'Fontes científicas e links para todas as informações médicas',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Todas as informações médicas, cálculos e escores fornecidos neste aplicativo são baseados em literatura médica revisada por pares e diretrizes estabelecidas. Abaixo estão as referências completas com links para as fontes originais.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ..._buildCitationsByCategory(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCitationsByCategory(BuildContext context) {
    final categories = [
      'Neurology',
      'Cardiology',
      'Emergency Medicine',
      'Nephrology',
      'Pediatrics',
      'General Medicine',
    ];

    return categories.map((category) {
      final citations = MedicalCitations.getCitationsByCategory(category);
      if (citations.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCategoryName(category),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            ...citations.map((citation) => _buildCitationCard(context, citation)),
          ],
        ),
      );
    }).toList();
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'Neurology':
        return 'Neurologia';
      case 'Cardiology':
        return 'Cardiologia';
      case 'Emergency Medicine':
        return 'Medicina de Emergência';
      case 'Nephrology':
        return 'Nefrologia';
      case 'Pediatrics':
        return 'Pediatria';
      case 'General Medicine':
        return 'Medicina Geral';
      default:
        return category;
    }
  }

  Widget _buildCitationCard(BuildContext context, CitationEntry citation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              citation.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              citation.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              citation.formattedCitation,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _launchUrl(citation.url!),
                    child: Text(
                      'Abrir fonte original',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
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
