import 'package:get/get.dart';
import 'package:navixplore/domain/entities/terms_and_conditions.dart';
import 'package:navixplore/domain/usecases/get_terms_and_conditions_usecase.dart';

class TermsAndConditionsViewModel extends GetxController {
  final GetTermsAndConditionsUseCase _getTermsAndConditionsUseCase;

  TermsAndConditionsViewModel(this._getTermsAndConditionsUseCase);

  final Rx<TermsAndConditions?> termsAndConditions =
      Rx<TermsAndConditions?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  Future<void> fetchTermsAndConditions() async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _getTermsAndConditionsUseCase.execute();
      termsAndConditions.value = result;
    } catch (e) {
      error.value = 'Failed to fetch terms and conditions: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
