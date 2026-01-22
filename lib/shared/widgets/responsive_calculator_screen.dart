import 'package:flutter/material.dart';

import 'responsive_layout.dart';

/// A responsive scaffold wrapper for calculator screens.
/// Constrains content width and centers it on wider screens.
class ResponsiveCalculatorScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const ResponsiveCalculatorScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
      ),
      body: ResponsiveContent(
        maxWidth: 600,
        child: body,
      ),
    );
  }
}
