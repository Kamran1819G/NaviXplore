// lib/data/models/terms_and_conditions_model.dart

import 'package:navixplore/domain/entities/terms_and_conditions.dart';

class TermsAndConditionsModel extends TermsAndConditions {
  TermsAndConditionsModel({
    required int id,
    required String content,
    required DateTime lastUpdated,
    required int version,
    required bool isCurrent,
  }) : super(
          id: id,
          content: content,
          lastUpdated: lastUpdated,
          version: version,
          isCurrent: isCurrent,
        );

  factory TermsAndConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsModel(
      id: json['id'] as int,
      content: json['content'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      version: json['version'] as int,
      isCurrent: json['is_current'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'last_updated': lastUpdated.toIso8601String(),
      'version': version,
      'is_current': isCurrent,
    };
  }
}
