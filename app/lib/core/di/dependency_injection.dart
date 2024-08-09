// lib/core/di/dependency_injection.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:navixplore/data/datasources/remote/remote_data_source.dart';
import 'package:navixplore/data/repositories/terms_and_conditions_repository.dart';
import 'package:navixplore/domain/repositories/i_terms_and_conditions_repository.dart';
import 'package:navixplore/domain/usecases/get_terms_and_conditions_usecase.dart';
import 'package:navixplore/presentation/viewmodels/terms_and_conditions_viewmodel.dart';

class DependencyInjection {
  static void init() {
    // Core
    Get.lazyPut(() => Supabase.instance.client, fenix: true);

    // Data Sources
    Get.lazyPut<RemoteDataSource>(
        () => RemoteDataSource(Get.find<SupabaseClient>()),
        fenix: true);

    // Repositories
    Get.lazyPut<ITermsAndConditionsRepository>(
      () => TermsAndConditionsRepository(Get.find<RemoteDataSource>()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
        () => GetTermsAndConditionsUseCase(
            Get.find<ITermsAndConditionsRepository>()),
        fenix: true);

    // ViewModels
    Get.lazyPut(
        () => TermsAndConditionsViewModel(
            Get.find<GetTermsAndConditionsUseCase>()),
        fenix: true);

    // Add more dependencies here as your app grows
  }

  // Helper method to register additional dependencies
  static void registerDependency<T>(InstanceBuilderCallback<T> builder) {
    Get.lazyPut<T>(builder, fenix: true);
  }
}
