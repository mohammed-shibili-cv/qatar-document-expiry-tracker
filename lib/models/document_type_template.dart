/// Seeded Qatar document type templates with sensible default renewal windows.
class DocumentTypeTemplate {
  const DocumentTypeTemplate({
    required this.id,
    required this.label,
    required this.defaultRenewalWindowDays,
    required this.description,
  });

  final String id;
  final String label;
  final int defaultRenewalWindowDays;
  final String description;

  static const List<DocumentTypeTemplate> qatarDefaults = [
    DocumentTypeTemplate(
      id: 'qid',
      label: 'QID',
      defaultRenewalWindowDays: 90,
      description: 'Qatar ID card',
    ),
    DocumentTypeTemplate(
      id: 'health_card',
      label: 'Health Card',
      defaultRenewalWindowDays: 60,
      description: 'Hamad / MoPH health card',
    ),
    DocumentTypeTemplate(
      id: 'residency_permit',
      label: 'Residency Permit',
      defaultRenewalWindowDays: 90,
      description: 'Residence permit linked to QID',
    ),
    DocumentTypeTemplate(
      id: 'istimara',
      label: 'Istimara',
      defaultRenewalWindowDays: 30,
      description: 'Vehicle registration certificate',
    ),
    DocumentTypeTemplate(
      id: 'driving_license',
      label: 'Driving License',
      defaultRenewalWindowDays: 60,
      description: 'Qatar driving licence',
    ),
    DocumentTypeTemplate(
      id: 'passport',
      label: 'Passport',
      defaultRenewalWindowDays: 180,
      description: 'Travel passport',
    ),
    DocumentTypeTemplate(
      id: 'vehicle_insurance',
      label: 'Vehicle Insurance',
      defaultRenewalWindowDays: 30,
      description: 'Compulsory motor insurance',
    ),
  ];

  static DocumentTypeTemplate? byId(String id) {
    for (final t in qatarDefaults) {
      if (t.id == id) return t;
    }
    return null;
  }

  static DocumentTypeTemplate custom({
    required String label,
    int defaultRenewalWindowDays = 30,
  }) {
    return DocumentTypeTemplate(
      id: 'custom',
      label: label,
      defaultRenewalWindowDays: defaultRenewalWindowDays,
      description: 'Custom document',
    );
  }
}
