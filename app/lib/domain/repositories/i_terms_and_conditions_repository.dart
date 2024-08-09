// lib/domain/repositories/i_terms_and_conditions_repository.dart

import 'package:navixplore/domain/entities/terms_and_conditions.dart';

abstract class ITermsAndConditionsRepository {
  Future<TermsAndConditions> getLatestTermsAndConditions();
}
