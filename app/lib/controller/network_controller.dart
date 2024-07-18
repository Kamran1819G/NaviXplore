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
      Get.snackbar(
          'No internet connection', 'Please check your internet connection',
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.wifi_off, color: Colors.white),
          shouldIconPulse: true,
          duration: Duration(seconds: 5),
          isDismissible: true
      );
    }else if(Get.isSnackbarOpen && (connectivityResultList.contains(ConnectivityResult.mobile) || connectivityResultList.contains(ConnectivityResult.wifi))){
      Get.closeCurrentSnackbar();
      Get.snackbar(
          'Internet connection restored', 'You are now connected to the internet',
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Icons.wifi, color: Colors.white),
          shouldIconPulse: false,
          duration: Duration(seconds: 5),
          isDismissible: true
      );
    }
    else{
      if(Get.isSnackbarOpen){
        Get.closeCurrentSnackbar();
      }
    }
  }
}