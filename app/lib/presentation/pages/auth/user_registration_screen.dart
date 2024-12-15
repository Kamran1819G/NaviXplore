import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navixplore/core/routes/app_routes.dart';
import 'package:navixplore/presentation/controllers/user_registration_controller.dart';

class UserRegistrationScreen extends StatelessWidget {
  final UserRegistrationController controller =
      Get.put(UserRegistrationController());
  final PageController pageController = PageController();

  UserRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Complete Your Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 0.0, // You can update this based on the current page
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildProfilePicturePage(context),
                _buildUsernamePage(),
                _buildNameAndBioPage(),
              ],
            ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildProfilePicturePage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose a profile picture',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.h),
          Obx(() => GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: CircleAvatar(
                  radius: 80.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: controller.imageFile.value != null
                      ? FileImage(File(controller.imageFile.value!.path))
                      : null,
                  child: controller.imageFile.value == null
                      ? Icon(Icons.camera_alt,
                          size: 50.sp, color: Colors.grey[600])
                      : null,
                ),
              )),
          SizedBox(height: 20.h),
          Text(
            'Tap to select an image',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernamePage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose a username',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.h),
          TextField(
            controller: controller.usernameController,
            onChanged: controller.validateUsername,
            decoration: InputDecoration(
              labelText: 'Username',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              prefixIcon: Icon(Icons.person),
              suffixIcon: Obx(() => Icon(
                    controller.isUsernameValid.value
                        ? Icons.check
                        : Icons.close,
                    color: controller.isUsernameValid.value
                        ? Colors.green
                        : Colors.red,
                  )),
              helperText:
                  'Username must be at least 3 characters and contain only letters, numbers, and underscores',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndBioPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.h),
          TextField(
            controller: controller.nameController,
            onChanged: controller.validateName,
            decoration: InputDecoration(
              labelText: 'Full Name',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              prefixIcon: Icon(Icons.person_outline),
              suffixIcon: Obx(() => Icon(
                    controller.isNameValid.value ? Icons.check : Icons.close,
                    color: controller.isNameValid.value
                        ? Colors.green
                        : Colors.red,
                  )),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: controller.bioController,
            onChanged: controller.validateBio,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              prefixIcon: Icon(Icons.description),
              suffixIcon: Obx(() => Icon(
                    controller.isBioValid.value ? Icons.check : Icons.close,
                    color:
                        controller.isBioValid.value ? Colors.green : Colors.red,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              if (pageController.page!.round() > 0) {
                pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text('Back'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (pageController.page!.round() < 2) {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          if (await controller.completeRegistration()) {
                            Get.offAllNamed(AppRoutes.HOME);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        pageController.page?.round() == 2 ? "Complete" : "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  controller.getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  controller.getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
