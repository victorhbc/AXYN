import 'package:flutter/material.dart';

import '../../core/services/disclaimer_service.dart';

/// Medical disclaimer dialog that must be shown to users
class MedicalDisclaimerDialog extends StatelessWidget {
  final bool isFirstLaunch;

  const MedicalDisclaimerDialog({
    super.key,
    this.isFirstLaunch = false,
  });

  /// Show the disclaimer dialog
  static Future<void> show(BuildContext context, {bool isFirstLaunch = false}) {
    return showDialog(
      context: context,
      barrierDismissible: !isFirstLaunch,
      builder: (context) => MedicalDisclaimerDialog(isFirstLaunch: isFirstLaunch),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aviso Médico Importante',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMPORTANTE - LEIA COM ATENÇÃO:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildDisclaimerItem(
                    context,
                    'Este aplicativo fornece informações médicas e cálculos de saúde para fins educacionais e de referência.',
                  ),
                  const SizedBox(height: 12),
                  _buildDisclaimerItem(
                    context,
                    'As informações fornecidas NÃO substituem o julgamento clínico profissional e NÃO constituem diagnóstico ou tratamento médico.',
                  ),
                  const SizedBox(height: 12),
                  _buildDisclaimerItem(
                    context,
                    'SEMPRE consulte um médico ou profissional de saúde qualificado antes de tomar qualquer decisão médica ou iniciar qualquer tratamento.',
                  ),
                  const SizedBox(height: 12),
                  _buildDisclaimerItem(
                    context,
                    'Nunca ignore ou atrase a busca de aconselhamento médico profissional devido a informações obtidas neste aplicativo.',
                  ),
                  const SizedBox(height: 12),
                  _buildDisclaimerItem(
                    context,
                    'O desenvolvedor não se responsabiliza por decisões clínicas tomadas com base nas informações deste aplicativo.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ao usar este aplicativo, você reconhece que:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'Você leu e entendeu este aviso',
            ),
            _buildBulletPoint(
              context,
              'Você buscará aconselhamento médico profissional antes de tomar decisões médicas',
            ),
            _buildBulletPoint(
              context,
              'Você assume total responsabilidade pelo uso das informações fornecidas',
            ),
          ],
        ),
      ),
      actions: [
        if (!isFirstLaunch)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        FilledButton.icon(
          onPressed: () async {
            await DisclaimerService.markDisclaimerAsSeen();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Entendi e Concordo'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 20,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
