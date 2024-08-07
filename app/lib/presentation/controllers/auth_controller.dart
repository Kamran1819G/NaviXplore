import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      isAuthenticated.value = session != null;
    });
  }

  User? get currentUser => supabase.auth.currentUser;

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await Supabase.instance.client.auth.signOut();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.AUTH_GATE);
  }
}
