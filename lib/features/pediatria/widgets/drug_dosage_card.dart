import 'package:flutter/material.dart';

import '../../../data/models/drug_dosage.dart';

/// Card widget displaying drug dosage information
class DrugDosageCard extends StatelessWidget {
  final DrugDosage drug;
  final double peso;

  const DrugDosageCard({
    super.key,
    required this.drug,
    required this.peso,
  });

  @override
  Widget build(BuildContext context) {
    final doseMinCalc = drug.calculateMinDose(peso);
    final doseMaxCalc = drug.calculateMaxDose(peso);
    final maxDailyCalc = drug.calculateMaxDaily(peso);

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
          subtitle: _buildSubtitle(context, doseMinCalc, doseMaxCalc),
          children: [
            _buildExpandedContent(context, doseMinCalc, doseMaxCalc, maxDailyCalc),
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

  Widget _buildSubtitle(
      BuildContext context, double doseMinCalc, double doseMaxCalc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        if (drug.restriction != null) _buildRestrictionBadge(context),
        _buildDoseText(context, doseMinCalc, doseMaxCalc),
      ],
    );
  }

  Widget _buildRestrictionBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        drug.restriction!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.amber.shade800,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildDoseText(
      BuildContext context, double doseMinCalc, double doseMaxCalc) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: drug.isDailyDose ? 'Dose diária: ' : 'Dose: ',
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: drug.doseMin == drug.doseMax
                ? '${doseMinCalc.toStringAsFixed(1)} mg'
                : '${doseMinCalc.toStringAsFixed(1)} – ${doseMaxCalc.toStringAsFixed(1)} mg',
            style: TextStyle(
              color: drug.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, double doseMinCalc,
      double doseMaxCalc, double? maxDailyCalc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Dose padrão', drug.getDoseRangeString()),
          _buildInfoRow(context, 'Frequência', drug.frequency),
          if (maxDailyCalc != null)
            _buildInfoRow(context, 'Dose máx. diária',
                '${maxDailyCalc.toStringAsFixed(1)} mg (${drug.maxDaily} mg/kg/dia)'),
          if (drug.maxDoses != null)
            _buildInfoRow(context, 'Máx. doses/dia', '${drug.maxDoses} doses'),
          if (drug.divisions != null)
            _buildDivisionsSection(context, doseMaxCalc),
          if (drug.observation != null) _buildObservation(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionsSection(BuildContext context, double doseMaxCalc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Dose por tomada:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: drug.divisions!.map((div) {
            final dosePerTake = doseMaxCalc / div;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: drug.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$div×/dia: ${dosePerTake.toStringAsFixed(1)} mg',
                style: TextStyle(
                  color: drug.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                drug.observation!,
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
