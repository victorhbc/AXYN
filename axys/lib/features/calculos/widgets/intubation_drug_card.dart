import 'package:flutter/material.dart';

import '../data/intubation_drug_model.dart';

/// Custom drug card for intubation medications that displays volume in mL
class IntubationDrugCard extends StatelessWidget {
  final IntubationDrug drug;
  final double peso;

  const IntubationDrugCard({
    super.key,
    required this.drug,
    required this.peso,
  });

  @override
  Widget build(BuildContext context) {
    final totalDose = drug.calculateTotalDose(peso);
    final volume = drug.calculateVolume(peso);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: drug.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: drug.color.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: _buildLeadingIcon(),
          title: _buildTitle(context),
          subtitle: _buildSubtitle(context, volume, totalDose),
          children: [
            _buildExpandedContent(context, volume, totalDose),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: drug.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(drug.icon, color: drug.color, size: 24),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      drug.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSubtitle(BuildContext context, double volume, double totalDose) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildVolumeText(context, volume),
      ],
    );
  }

  Widget _buildVolumeText(BuildContext context, double volume) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          const TextSpan(
            text: 'Volume: ',
            style: TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: '${volume.toStringAsFixed(2)} mL',
            style: TextStyle(
              color: drug.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, double volume, double totalDose) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Volume a aplicar',
            '${volume.toStringAsFixed(2)} mL',
            isHighlight: true,
          ),
          _buildInfoRow(
            context,
            'Dose total',
            drug.isMcg
                ? '${totalDose.toStringAsFixed(1)} mcg'
                : '${totalDose.toStringAsFixed(1)} mg',
          ),
          _buildInfoRow(
            context,
            'Dose padrão',
            drug.getDoseString(),
          ),
          _buildInfoRow(
            context,
            'Concentração',
            drug.getConcentrationString(),
          ),
          if (drug.preparation != null)
            _buildInfoRow(
              context,
              'Preparo',
              drug.preparation!,
            ),
          _buildInfoRow(
            context,
            'Frequência',
            'Dose única',
          ),
          if (drug.observation.isNotEmpty) _buildObservation(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                    color: isHighlight ? drug.color : null,
                    fontSize: isHighlight ? 16 : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                drug.observation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
