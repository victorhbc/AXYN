import 'package:flutter/material.dart';

/// Helper class for getting colors based on medical classifications
abstract class ClassificationColors {
  static Color getColor(String? classification) {
    if (classification == null) return Colors.grey;

    switch (classification) {
      // IMC classifications
      case 'Abaixo do peso':
        return Colors.orange;
      case 'Peso normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidade Grau I':
        return Colors.deepOrange;
      case 'Obesidade Grau II':
        return Colors.red;
      case 'Obesidade Grau III':
        return Colors.red.shade900;

      // Creatinine Clearance classifications
      case 'Normal (G1)':
        return Colors.green;
      case 'Levemente diminuída (G2)':
        return Colors.lightGreen;
      case 'Leve a moderada (G3a)':
        return Colors.orange;
      case 'Moderada a severa (G3b)':
        return Colors.deepOrange;
      case 'Severamente diminuída (G4)':
        return Colors.red;
      case 'Falência Renal (G5)':
        return Colors.red.shade900;

      // Glasgow classifications
      case 'TCE Leve':
        return Colors.green;
      case 'TCE Moderado':
        return Colors.orange;
      case 'TCE Grave':
        return Colors.red;

      // Risk classifications
      case 'Baixo risco':
      case 'Baixo risco sangramento':
      case 'Baixa probabilidade':
        return Colors.green;
      case 'Risco moderado':
      case 'Risco moderado sangramento':
      case 'Probabilidade moderada':
        return Colors.orange;
      case 'Alto risco':
      case 'Alto risco sangramento':
      case 'Alta probabilidade':
        return Colors.red;

      // Sodium/Osmolarity
      case 'Normal':
        return Colors.green;
      case 'Hiponatremia':
      case 'Hipo-osmolar':
        return Colors.orange;
      case 'Hipernatremia':
      case 'Hiperosmolar':
        return Colors.red;

      // Other
      case 'Calculado':
        return Colors.blue;
      case 'Idade Gestacional':
        return Colors.purple;

      default:
        return Colors.blue;
    }
  }
}
