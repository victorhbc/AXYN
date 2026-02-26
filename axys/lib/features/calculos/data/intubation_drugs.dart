import 'package:flutter/material.dart';

import 'intubation_drug_model.dart';

/// Drug category for intubation medications
class IntubationDrugCategory {
  final String name;
  final List<IntubationDrug> drugs;

  const IntubationDrugCategory({
    required this.name,
    required this.drugs,
  });
}

/// Predefined list of intubation drug dosages organized by category
class IntubationDrugs {
  static const List<IntubationDrugCategory> categories = [
    IntubationDrugCategory(
      name: 'PRÉ-MEDICAÇÃO',
      drugs: [
        IntubationDrug(
          name: 'Lidocaína',
          icon: Icons.medication_liquid,
          color: Colors.blue,
          doseMgKg: 1.5,
          concentration: 20.0, // 20 mg/mL (Lidocaína 2%)
          observation: 'Reduz a incidência de laringoespasmo',
        ),
        IntubationDrug(
          name: 'Fentanil',
          icon: Icons.medication,
          color: Colors.purple,
          doseMgKg: 2.0,
          concentration: 50.0, // 50 mcg/mL
          observation: 'Dose: 2 mcg/kg',
          isMcg: true,
        ),
      ],
    ),
    IntubationDrugCategory(
      name: 'INDUÇÃO/SEDAÇÃO',
      drugs: [
        IntubationDrug(
          name: 'Cetamina',
          icon: Icons.medication_liquid,
          color: Colors.orange,
          doseMgKg: 2.0,
          concentration: 50.0, // 50 mg/mL
          observation: 'Dose: 2 mg/kg',
        ),
        IntubationDrug(
          name: 'Etomidato',
          icon: Icons.medication,
          color: Colors.teal,
          doseMgKg: 0.3,
          concentration: 2.0, // 2 mg/mL
          observation: 'Dose: 0,3 mg/kg',
        ),
        IntubationDrug(
          name: 'Midazolam',
          icon: Icons.medication_liquid,
          color: Colors.indigo,
          doseMgKg: 0.15,
          concentration: 5.0, // 5 mg/mL
          observation: 'Dose: 0,15 mg/kg',
        ),
        IntubationDrug(
          name: 'Propofol 1%',
          icon: Icons.medication,
          color: Colors.green,
          doseMgKg: 1.5,
          concentration: 10.0, // 10 mg/mL (Propofol 1%)
          observation: 'Dose: 1,5 mg/kg',
        ),
        IntubationDrug(
          name: 'Propofol 2%',
          icon: Icons.medication,
          color: const Color(0xFF2E7D32), // green.shade700 equivalent
          doseMgKg: 1.5,
          concentration: 20.0, // 20 mg/mL (Propofol 2%)
          observation: 'Dose: 1,5 mg/kg',
        ),
      ],
    ),
    IntubationDrugCategory(
      name: 'BLOQUEIO NEUROMUSCULAR',
      drugs: [
        IntubationDrug(
          name: 'Succinilcolina',
          icon: Icons.medication,
          color: Colors.red,
          doseMgKg: 1.0,
          concentration: 10.0, // Após preparo: 1 FR (100 mg) + 10 mL AD = 10 mg/mL
          preparation: 'Preparo: 1 FR (100 mg) + 10 mL AD\n[1 mL = 10 mg]',
          observation: 'Está em ordem de preferência',
        ),
        IntubationDrug(
          name: 'Atracúrio',
          icon: Icons.medication_liquid,
          color: Colors.deepOrange,
          doseMgKg: 0.5,
          concentration: 5.0, // Após preparo: 5 mL (50 mg) + 5 mL AD = 5 mg/mL
          preparation: 'Preparo: 5 mL (50 mg) + 5 mL AD\n[1 mL = 5 mg]',
          observation: 'Está em ordem de preferência',
        ),
        IntubationDrug(
          name: 'Rocurônio',
          icon: Icons.medication,
          color: Colors.pink,
          doseMgKg: 1.2,
          concentration: 10.0, // 10 mg/mL
          observation: 'Dose: 1,2 mg/kg\nEstá em ordem de preferência',
        ),
        IntubationDrug(
          name: 'Cisatracúrio',
          icon: Icons.medication_liquid,
          color: Colors.brown,
          doseMgKg: 0.2,
          concentration: 2.0, // 2 mg/mL
          observation: 'Dose: 0,2 mg/kg\nEstá em ordem de preferência',
        ),
        IntubationDrug(
          name: 'Pancurônio',
          icon: Icons.medication,
          color: Colors.deepPurple,
          doseMgKg: 0.08,
          concentration: 2.0, // 2 mg/mL
          observation: 'Dose: 0,08 mg/kg\nEstá em ordem de preferência',
        ),
      ],
    ),
  ];
}
