import 'package:flutter/material.dart';

/// Expandable card for legal content sections
class ExpandableSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

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
          leading: _buildLeadingIcon(context),
          title: _buildTitle(context),
          children: [_buildContent(context)],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }
}
