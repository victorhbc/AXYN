import 'package:flutter/material.dart';

/// Model representing a drug dosage information
class DrugDosage {
  final String name;
  final IconData icon;
  final Color color;
  final double doseMin;
  final double doseMax;
  final String frequency;
  final double? maxDaily;
  final int? maxDoses;
  final String? observation;
  final String? restriction;
  final bool isDailyDose;
  final List<int>? divisions;

  const DrugDosage({
    required this.name,
    required this.icon,
    required this.color,
    required this.doseMin,
    required this.doseMax,
    required this.frequency,
    this.maxDaily,
    this.maxDoses,
    this.observation,
    this.restriction,
    this.isDailyDose = false,
    this.divisions,
  });

  /// Calculate minimum dose based on weight
  double calculateMinDose(double peso) => peso * doseMin;

  /// Calculate maximum dose based on weight
  double calculateMaxDose(double peso) => peso * doseMax;

  /// Calculate maximum daily dose based on weight
  double? calculateMaxDaily(double peso) =>
      maxDaily != null ? peso * maxDaily! : null;

  /// Get dose range string for display
  String getDoseRangeString() =>
      '${doseMin}–${doseMax} mg/kg${isDailyDose ? '/dia' : '/dose'}';
}
