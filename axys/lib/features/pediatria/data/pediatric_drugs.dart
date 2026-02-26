import 'package:flutter/material.dart';

import '../../../data/models/drug_dosage.dart';

/// Predefined list of pediatric drug dosages
class PediatricDrugs {
  static const List<DrugDosage> all = [
    DrugDosage(
      name: 'Paracetamol',
      icon: Icons.healing,
      color: Colors.blue,
      doseMin: 10,
      doseMax: 15,
      frequency: 'a cada 4–6 horas',
      maxDaily: 75,
      maxDoses: 4,
      observation: 'Geralmente máx. 4 doses/dia',
    ),
    DrugDosage(
      name: 'Ibuprofeno',
      icon: Icons.local_pharmacy,
      color: Colors.orange,
      doseMin: 5,
      doseMax: 10,
      frequency: 'a cada 6–8 horas',
      maxDaily: 40,
      maxDoses: 3,
      observation: 'Uso apenas acima de 6 meses',
      restriction: '> 6 meses',
    ),
    DrugDosage(
      name: 'Dipirona',
      icon: Icons.medication_liquid,
      color: Colors.purple,
      doseMin: 10,
      doseMax: 15,
      frequency: 'a cada 6–8 horas',
      maxDoses: 4,
      observation: 'Respeitar protocolos institucionais',
    ),
    DrugDosage(
      name: 'Amoxicilina',
      icon: Icons.vaccines,
      color: Colors.green,
      doseMin: 25,
      doseMax: 50,
      frequency: '2 a 3 tomadas por dia',
      isDailyDose: true,
      divisions: [2, 3],
      observation: 'Duração típica: 7–10 dias',
    ),
    DrugDosage(
      name: 'Loratadina',
      icon: Icons.air,
      color: Colors.teal,
      doseMin: 0.2,
      doseMax: 0.2,
      frequency: '1 vez ao dia',
      isDailyDose: true,
      observation: 'Indicação: rinite alérgica, urticária',
    ),
  ];
}
