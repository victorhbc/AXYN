import 'package:flutter/material.dart';

/// Model representing a calculator item in the grid
class CalculoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? page;
  final String? storeKey;
  final String? resultUnit;

  const CalculoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.page,
    this.storeKey,
    this.resultUnit,
  });
}
