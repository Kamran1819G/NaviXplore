import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }

  void updateConnectionStatus(List<ConnectivityResult> connectivityResultList) {
    if (connectivityResultList.contains(ConnectivityResult.none)) {
      Get.showSnackbar(
        const GetSnackBar(
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
          ),
          message: 'Please check your internet connection',
          isDismissible: false,
          backgroundColor: Colors.red,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
    } else if (Get.isSnackbarOpen &&
        (connectivityResultList.contains(ConnectivityResult.mobile) ||
            connectivityResultList.contains(ConnectivityResult.wifi))) {
      Get.closeCurrentSnackbar();
      Get.showSnackbar(
        const GetSnackBar(
          icon: const Icon(
            Icons.wifi,
            color: Colors.white,
          ),
          message: 'You are now connected to the internet',
          isDismissible: true,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          borderRadius: 8,
        ),
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
