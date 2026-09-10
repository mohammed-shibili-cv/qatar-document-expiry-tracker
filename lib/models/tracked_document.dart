/// A locally stored personal document with expiry tracking.
///
/// [documentNumber] is sensitive — never log it; the Hive documents box
/// is AES-encrypted at rest when the platform supports secure key storage.
class TrackedDocument {
  TrackedDocument({
    required this.id,
    required this.typeId,
    required this.typeLabel,
    this.documentNumber,
    this.issueDate,
    required this.expiryDate,
    required this.renewalWindowDays,
    this.notes,
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String typeId;
  final String typeLabel;

  /// Sensitive identifier (e.g. QID). Prefer empty over logging.
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime expiryDate;
  final int renewalWindowDays;
  final String? notes;

  /// Local filesystem path to an optional gallery / camera attachment.
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get daysRemaining {
    final today = DateTime.now();
    final expiryDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    final todayDay = DateTime(today.year, today.month, today.day);
    return expiryDay.difference(todayDay).inDays;
  }

  bool get isExpired => daysRemaining < 0;

  bool get isInRenewalWindow {
    final days = daysRemaining;
    return days >= 0 && days <= renewalWindowDays;
  }

  TrackedDocument copyWith({
    String? id,
    String? typeId,
    String? typeLabel,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    int? renewalWindowDays,
    String? notes,
    String? photoPath,
    bool clearDocumentNumber = false,
    bool clearIssueDate = false,
    bool clearNotes = false,
    bool clearPhotoPath = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackedDocument(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      typeLabel: typeLabel ?? this.typeLabel,
      documentNumber:
          clearDocumentNumber ? null : (documentNumber ?? this.documentNumber),
      issueDate: clearIssueDate ? null : (issueDate ?? this.issueDate),
      expiryDate: expiryDate ?? this.expiryDate,
      renewalWindowDays: renewalWindowDays ?? this.renewalWindowDays,
      notes: clearNotes ? null : (notes ?? this.notes),
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeId': typeId,
      'typeLabel': typeLabel,
      'documentNumber': documentNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'renewalWindowDays': renewalWindowDays,
      'notes': notes,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TrackedDocument.fromMap(Map<dynamic, dynamic> map) {
    return TrackedDocument(
      id: map['id'] as String,
      typeId: map['typeId'] as String,
      typeLabel: map['typeLabel'] as String,
      documentNumber: map['documentNumber'] as String?,
      issueDate: map['issueDate'] != null
          ? DateTime.parse(map['issueDate'] as String)
          : null,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      renewalWindowDays: map['renewalWindowDays'] as int,
      notes: map['notes'] as String?,
      photoPath: map['photoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Safe summary for debugging — never includes [documentNumber].
  @override
  String toString() =>
      'TrackedDocument(id: $id, type: $typeLabel, expiry: $expiryDate)';
}
