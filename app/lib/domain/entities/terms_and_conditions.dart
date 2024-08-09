// lib/domain/entities/terms_and_conditions.dart

class TermsAndConditions {
  final int id;
  final String content;
  final DateTime lastUpdated;
  final int version;
  final bool isCurrent;

  TermsAndConditions({
    required this.id,
    required this.content,
    required this.lastUpdated,
    required this.version,
    required this.isCurrent,
  });
}
