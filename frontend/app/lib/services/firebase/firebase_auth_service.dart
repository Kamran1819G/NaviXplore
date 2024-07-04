import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navixplore/utils/snackbar_util.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailAndPassword(
      {required String email, required String password, required String fullName}) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null && currentUser.isAnonymous) {
      final credential =
      EmailAuthProvider.credential(email: email, password: password);
      await currentUser.linkWithCredential(credential);

      await _firestore.collection('users').doc(currentUser.uid).set({
        'name': fullName,
        'email': email,
      });
    } else {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignInAccount = await GoogleSignIn().signIn();

      if (googleSignInAccount == null) {
        return; // User canceled the sign-in
      }

      final googleSignInAuthentication = await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

        if (!docSnapshot.exists) {
          showCustomSnackBar(context, 'User does not exist. Please sign up first.', Colors.red);
          await _auth.signOut();
        }
      }
    } catch (e) {
      showCustomSnackBar(context, e.toString(), Colors.red);
    }
  }

  Future<void> signUpWithGoogle() async {
    final googleSignInAccount = await GoogleSignIn().signIn();

    final googleSignInAuthentication = await googleSignInAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
      });
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

        if (!docSnapshot.exists) {
          showCustomSnackBar(context, 'User does not exist. Please sign up first.', Colors.red);
          await _auth.signOut();
        }
      }
    } catch (e) {
      showCustomSnackBar(context, e.toString(), Colors.red);
    }
  }


  Future<void> signUpWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
