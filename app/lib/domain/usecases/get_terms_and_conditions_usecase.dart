// lib/domain/usecases/get_terms_and_conditions_usecase.dart

import 'package:navixplore/domain/entities/terms_and_conditions.dart';
import 'package:navixplore/domain/repositories/i_terms_and_conditions_repository.dart';

class GetTermsAndConditionsUseCase {
  final ITermsAndConditionsRepository repository;

  GetTermsAndConditionsUseCase(this.repository);

  Future<TermsAndConditions> execute() async {
    return await repository.getLatestTermsAndConditions();
  }
}
