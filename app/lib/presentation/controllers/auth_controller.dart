import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isAuthenticated = false.obs;
  var isRegistered = false.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      isLoading.value = true;

      if (user != null) {
        isAuthenticated.value = true;
        // Check if user is registered
        isRegistered.value = await _checkUserRegistration(user.uid);
      } else {
        isAuthenticated.value = false;
        isRegistered.value = false;
      }

      isLoading.value = false;
    });
  }

  Future<bool> _checkUserRegistration(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      isAuthenticated.value = false;
      isRegistered.value = false;
      Get.offAllNamed(AppRoutes.AUTH_GATE);
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
