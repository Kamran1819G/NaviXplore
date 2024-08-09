// lib/data/datasources/remote/remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:navixplore/data/models/terms_and_conditions_model.dart';

class RemoteDataSource {
  final SupabaseClient _supabaseClient;

  RemoteDataSource(this._supabaseClient);

  Future<TermsAndConditionsModel> getLatestTermsAndConditions() async {
    try {
      final data = await _supabaseClient
          .from('terms_and_conditions')
          .select()
          .eq('is_current', true)
          .single();

      return TermsAndConditionsModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch terms and conditions: $e');
    }
  }

  // Add more remote data fetching methods here as your app grows
  // For example:
  // Future<UserModel> getUserProfile(String userId) async { ... }
  // Future<List<ProductModel>> getProducts() async { ... }
}
