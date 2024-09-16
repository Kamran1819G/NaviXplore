import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      isAuthenticated.value = user != null;
    });
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.AUTH_GATE);
  }
}
