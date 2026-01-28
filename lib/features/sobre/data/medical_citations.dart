/// Medical citations and references for all medical information in the app
class MedicalCitations {
  /// Citation entry with title, authors, journal, year, and URL
  static const List<CitationEntry> allCitations = [
    // Glasgow Coma Scale
    CitationEntry(
      title: 'Glasgow Coma Scale',
      description: 'Assessment of coma and impaired consciousness',
      authors: 'Teasdale G, Jennett B',
      journal: 'Lancet',
      year: '1974',
      volume: '2',
      pages: '81-84',
      doi: '10.1016/S0140-6736(74)91639-0',
      url: 'https://pubmed.ncbi.nlm.nih.gov/4136544/',
      category: 'Neurology',
    ),
    CitationEntry(
      title: 'Glasgow Coma Scale-Pupils Score',
      description: 'GCS-P: A new prognostic score combining Glasgow Coma Scale and pupil reactivity',
      authors: 'Balestreri M, Czosnyka M, Chatfield DA, et al.',
      journal: 'Intensive Care Med',
      year: '2004',
      volume: '30',
      pages: '1612-1616',
      doi: '10.1007/s00134-004-2311-8',
      url: 'https://pubmed.ncbi.nlm.nih.gov/15241528/',
      category: 'Neurology',
    ),

    // CHA2DS2-VA Score
    CitationEntry(
      title: 'CHA₂DS₂-VA Score',
      description: 'Refining clinical risk stratification for predicting stroke and thromboembolism in atrial fibrillation using a novel risk factor-based approach',
      authors: 'Lip GYH, Nieuwlaat R, Pisters R, Lane DA, Crijns HJGM',
      journal: 'Chest',
      year: '2010',
      volume: '137',
      pages: '263-272',
      doi: '10.1378/chest.09-1584',
      url: 'https://pubmed.ncbi.nlm.nih.gov/19762550/',
      category: 'Cardiology',
    ),
    CitationEntry(
      title: '2020 ESC Guidelines for Atrial Fibrillation',
      description: 'European Society of Cardiology guidelines on atrial fibrillation',
      authors: 'Hindricks G, Potpara T, Dagres N, et al.',
      journal: 'Eur Heart J',
      year: '2021',
      volume: '42',
      pages: '373-498',
      doi: '10.1093/eurheartj/ehaa612',
      url: 'https://pubmed.ncbi.nlm.nih.gov/32860505/',
      category: 'Cardiology',
    ),

    // HAS-BLED Score
    CitationEntry(
      title: 'HAS-BLED Score',
      description: 'A novel user-friendly score (HAS-BLED) to assess 1-year risk of major bleeding in patients with atrial fibrillation',
      authors: 'Pisters R, Lane DA, Nieuwlaat R, de Vos CB, Crijns HJGM, Lip GYH',
      journal: 'Chest',
      year: '2010',
      volume: '138',
      pages: '1093-1100',
      doi: '10.1378/chest.10-0134',
      url: 'https://pubmed.ncbi.nlm.nih.gov/20299623/',
      category: 'Cardiology',
    ),

    // Wells Score for PE
    CitationEntry(
      title: 'Wells Score for Pulmonary Embolism',
      description: 'Derivation of a simple clinical model to categorize patients probability of pulmonary embolism',
      authors: 'Wells PS, Anderson DR, Rodger M, et al.',
      journal: 'Thromb Haemost',
      year: '2000',
      volume: '83',
      pages: '416-420',
      doi: '10.1055/s-0037-1613830',
      url: 'https://pubmed.ncbi.nlm.nih.gov/10744147/',
      category: 'Emergency Medicine',
    ),
    CitationEntry(
      title: 'Simplified Wells Score',
      description: 'Excluding pulmonary embolism at the bedside without diagnostic imaging',
      authors: 'Wells PS, Anderson DR, Rodger M, et al.',
      journal: 'Ann Intern Med',
      year: '2001',
      volume: '135',
      pages: '98-107',
      doi: '10.7326/0003-4819-135-2-200107170-00010',
      url: 'https://pubmed.ncbi.nlm.nih.gov/11453709/',
      category: 'Emergency Medicine',
    ),

    // BMI/IMC
    CitationEntry(
      title: 'Body Mass Index',
      description: 'Quetelet Index (BMI) - World Health Organization classification',
      authors: 'World Health Organization',
      journal: 'WHO Technical Report Series',
      year: '2000',
      volume: '894',
      pages: '1-253',
      url: 'https://www.who.int/publications/i/item/924120894X',
      category: 'General Medicine',
    ),

    // Creatinine Clearance
    CitationEntry(
      title: 'Cockcroft-Gault Formula',
      description: 'Prediction of creatinine clearance from serum creatinine',
      authors: 'Cockcroft DW, Gault MH',
      journal: 'Nephron',
      year: '1976',
      volume: '16',
      pages: '31-41',
      doi: '10.1159/000180580',
      url: 'https://pubmed.ncbi.nlm.nih.gov/1244564/',
      category: 'Nephrology',
    ),
    CitationEntry(
      title: 'MDRD Study Equation',
      description: 'A more accurate method to estimate glomerular filtration rate from serum creatinine',
      authors: 'Levey AS, Bosch JP, Lewis JB, et al.',
      journal: 'Ann Intern Med',
      year: '1999',
      volume: '130',
      pages: '461-470',
      doi: '10.7326/0003-4819-130-6-199903160-00002',
      url: 'https://pubmed.ncbi.nlm.nih.gov/10075613/',
      category: 'Nephrology',
    ),

    // Pediatric Dosages
    CitationEntry(
      title: 'Pediatric Drug Dosing Guidelines',
      description: 'Sociedade Brasileira de Pediatria - Guia de Medicamentos',
      authors: 'Sociedade Brasileira de Pediatria',
      journal: 'SBP',
      year: '2023',
      url: 'https://www.sbp.com.br/',
      category: 'Pediatrics',
    ),
    CitationEntry(
      title: 'WHO Model List of Essential Medicines for Children',
      description: 'World Health Organization Essential Medicines List',
      authors: 'World Health Organization',
      journal: 'WHO',
      year: '2023',
      url: 'https://www.who.int/publications/i/item/WHO-MHP-HPS-EML-2023.02',
      category: 'Pediatrics',
    ),

    // Intubation Drugs
    CitationEntry(
      title: 'Rapid Sequence Intubation',
      description: 'Emergency airway management - Rapid sequence intubation protocols',
      authors: 'American Heart Association',
      journal: 'AHA Guidelines',
      year: '2020',
      url: 'https://cpr.heart.org/en/resuscitation-science/cpr-and-ecc-guidelines',
      category: 'Emergency Medicine',
    ),
    CitationEntry(
      title: 'Pediatric Advanced Life Support',
      description: 'PALS guidelines for pediatric emergency care',
      authors: 'American Heart Association',
      journal: 'AHA PALS',
      year: '2020',
      url: 'https://cpr.heart.org/en/courses/pediatric-advanced-life-support',
      category: 'Pediatrics',
    ),
  ];

  /// Get citations by category
  static List<CitationEntry> getCitationsByCategory(String category) {
    return allCitations.where((c) => c.category == category).toList();
  }

  /// Get citations for a specific calculator/score
  static List<CitationEntry> getCitationsForCalculator(String calculatorName) {
    switch (calculatorName.toLowerCase()) {
      case 'glasgow':
      case 'glasgow coma scale':
      case 'gcs':
        return allCitations.where((c) => c.category == 'Neurology').toList();
      case 'cha2ds2-va':
      case 'cha2ds2':
        return allCitations.where((c) => c.title.contains('CHA') || c.category == 'Cardiology').toList();
      case 'has-bled':
      case 'hasbled':
        return allCitations.where((c) => c.title.contains('HAS-BLED') || c.category == 'Cardiology').toList();
      case 'wells':
      case 'wells tep':
      case 'pulmonary embolism':
        return allCitations.where((c) => c.title.contains('Wells') || c.category == 'Emergency Medicine').toList();
      case 'imc':
      case 'bmi':
        return allCitations.where((c) => c.title.contains('BMI') || c.title.contains('Body Mass')).toList();
      case 'clearance':
      case 'creatinine':
        return allCitations.where((c) => c.category == 'Nephrology').toList();
      case 'pediatria':
      case 'pediatric':
        return allCitations.where((c) => c.category == 'Pediatrics').toList();
      case 'intubation':
        return allCitations.where((c) => c.title.contains('Intubation') || c.title.contains('PALS')).toList();
      default:
        return [];
    }
  }
}

/// Individual citation entry
class CitationEntry {
  final String title;
  final String description;
  final String authors;
  final String journal;
  final String year;
  final String? volume;
  final String? pages;
  final String? doi;
  final String? url;
  final String category;

  const CitationEntry({
    required this.title,
    required this.description,
    required this.authors,
    required this.journal,
    required this.year,
    this.volume,
    this.pages,
    this.doi,
    this.url,
    required this.category,
  });

  String get formattedCitation {
    final parts = <String>[
      authors,
      '$title. $journal',
      if (year.isNotEmpty) year,
      if (volume != null) ';$volume',
      if (pages != null) ':$pages',
    ];
    return parts.join(' ');
  }
}
