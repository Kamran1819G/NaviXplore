import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart'; // Import UserModel

class UserRegistrationController extends GetxController {
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final Rx<XFile?> imageFile = Rx<XFile?>(null);
  final isUsernameValid = false.obs;
  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onClose() {
    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void validateUsername(String username) {
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    isUsernameValid.value =
        username.length >= 3 && usernameRegex.hasMatch(username);
  }

  Future<void> getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        imageFile.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<bool> completeRegistration() async {
    if (!isUsernameValid.value) {
      Get.showSnackbar(
        const GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message:
          'Username must be at least 3 characters and contain only letters, numbers, and underscores',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
      return false;
    }

    if (nameController.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message: 'Please enter a valid name',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
      return false;
    }

    if (bioController.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          message: 'Please write a bio',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
      return false;
    }

    isLoading.value = true;
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      String username = usernameController.text.toLowerCase();
      DocumentReference usernameDoc =
      _firestore.collection('usernames').doc(username);

      bool success = await _firestore.runTransaction((transaction) async {
        DocumentSnapshot usernameSnapshot = await transaction.get(usernameDoc);

        if (usernameSnapshot.exists) {
          return false; // Username already exists
        }

        String? imageUrl;
        if (imageFile.value != null) {
          imageUrl = await _uploadImage(user.uid);
        }

        // Create both documents in the same transaction
        transaction.set(usernameDoc, {'uid': user.uid});

        UserModel newUser = UserModel(
          uid: user.uid,
          username: username,
          displayName: nameController.text,
          bio: bioController.text,
          profileImage: imageUrl,
        );

        transaction.set(_firestore.collection('users').doc(user.uid),
            newUser.toFirestore()
        );

        return true;
      });

      isLoading.value = false;

      if (!success) {
        Get.showSnackbar(
          const GetSnackBar(
            icon: const Icon(
              Icons.error,
              color: Colors.white,
            ),
            message: 'Username is already taken',
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            borderRadius: 8,
          ),
        );
        return false;
      }

      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<String> _uploadImage(String userId) async {
    try {
      Reference storageReference =
      _storage.ref().child('user_profiles/$userId');
      UploadTask uploadTask =
      storageReference.putFile(File(imageFile.value!.path));

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}