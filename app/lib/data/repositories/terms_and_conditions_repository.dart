// lib/data/repositories/terms_and_conditions_repository.dart

import 'package:navixplore/data/datasources/remote/remote_data_source.dart';
import 'package:navixplore/domain/entities/terms_and_conditions.dart';
import 'package:navixplore/domain/repositories/i_terms_and_conditions_repository.dart';

class TermsAndConditionsRepository implements ITermsAndConditionsRepository {
  final RemoteDataSource _remoteDataSource;

  TermsAndConditionsRepository(this._remoteDataSource);

  @override
  Future<TermsAndConditions> getLatestTermsAndConditions() async {
    final termsAndConditionsModel =
        await _remoteDataSource.getLatestTermsAndConditions();
    return termsAndConditionsModel;
  }
}
