import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRegistrationController extends GetxController {
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final isUsernameValid = false.obs;
  final isNameValid = false.obs;
  final isBioValid = false.obs;
  final isLoading = false.obs;

  void validateUsername(String username) {
    isUsernameValid.value = username.length >= 3;
  }

  void validateName(String name) {
    isNameValid.value = name.length >= 3;
  }

  void validateBio(String bio) {
    isBioValid.value = bio.length >= 3;
  }

  Future<void> registerUser() async {
    if (!isUsernameValid.value) {
      Get.snackbar('Error', 'Username must be at least 3 characters',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    if (!isNameValid.value) {
      Get.snackbar('Error', 'Name must be at least 3 characters',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    if (!isBioValid.value) {
      Get.snackbar('Error', 'Bio must be at least 3 characters',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    isLoading.value = true;

    // Register user
    isLoading.value = false;
  }
}
