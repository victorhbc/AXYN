import 'package:flutter/material.dart';

/// Model for intubation medications with concentration information
class IntubationDrug {
  final String name;
  final IconData icon;
  final Color color;
  final double doseMgKg; // Dose em mg/kg (ou mcg/kg para Fentanil)
  final double concentration; // Concentração em mg/mL (ou mcg/mL para Fentanil)
  final String? preparation; // Instruções de preparo
  final String observation; // Observações adicionais
  final bool isMcg; // Se true, a dose e concentração são em mcg

  const IntubationDrug({
    required this.name,
    required this.icon,
    required this.color,
    required this.doseMgKg,
    required this.concentration,
    this.preparation,
    required this.observation,
    this.isMcg = false,
  });

  /// Calculate total dose based on weight
  double calculateTotalDose(double peso) {
    return peso * doseMgKg;
  }

  /// Calculate volume in mL to be administered
  double calculateVolume(double peso) {
    final totalDose = calculateTotalDose(peso);
    return totalDose / concentration;
  }

  /// Get dose string for display
  String getDoseString() {
    if (isMcg) {
      return '${doseMgKg.toStringAsFixed(isMcg ? 0 : 1)} mcg/kg';
    }
    return '${doseMgKg.toStringAsFixed(1)} mg/kg';
  }

  /// Get concentration string for display
  String getConcentrationString() {
    if (isMcg) {
      return '${concentration.toStringAsFixed(0)} mcg/mL';
    }
    return '${concentration.toStringAsFixed(0)} mg/mL';
  }
}
