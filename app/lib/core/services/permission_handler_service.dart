import 'package:permission_handler/permission_handler.dart';

// Custom Interface
abstract class PermissionHandler {
  Future<bool> requestCameraPermission();

  Future<bool> requestNotificationPermission();

  Future<bool> requestLocationPermission();

  Future<bool> requestStoragePermission();

  Future<bool> requestMicrophonePermission();

  Future<bool> requestMultiplePermissions();

  Future<bool> checkPermissionStatus(Permission permission);

  Future<void> openAppSettings();
}

// implementation class
class PermissionHandlerImpl implements PermissionHandler {
  final Map<Permission, bool> _permissionCache = {};
  @override
  Future<bool> requestCameraPermission() async {
    final permission = Permission.camera;
    if (_permissionCache[permission] != null && _permissionCache[permission]!) {
      return true;
    }
    if (!await permission.isGranted) {
      await permission.request();
    }

    final status = await permission.isGranted;

    if(status){
      _permissionCache[permission] = true;
    }

    return status;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final permission = Permission.notification;
    if (_permissionCache[permission] != null && _permissionCache[permission]!) {
      return true;
    }
    if (!await permission.isGranted) {
      await permission.request();
    }
    final status = await permission.isGranted;

    if(status){
      _permissionCache[permission] = true;
    }

    return status;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = Permission.location;
    if (_permissionCache[permission] != null && _permissionCache[permission]!) {
      return true;
    }
    if (!await permission.isGranted) {
      await permission.request();
    }
    final status = await permission.isGranted;
    if(status){
      _permissionCache[permission] = true;
    }
    return status;
  }

  @override
  Future<bool> requestStoragePermission() async {
    final permission = Permission.storage;
    if (_permissionCache[permission] != null && _permissionCache[permission]!) {
      return true;
    }
    if (!await permission.isGranted) {
      await permission.request();
    }
    final status = await permission.isGranted;

    if(status){
      _permissionCache[permission] = true;
    }
    return status;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final permission = Permission.microphone;
    if (_permissionCache[permission] != null && _permissionCache[permission]!) {
      return true;
    }
    if (!await permission.isGranted) {
      await permission.request();
    }
    final status = await permission.isGranted;
    if(status){
      _permissionCache[permission] = true;
    }
    return status;
  }


  @override
  Future<bool> requestMultiplePermissions() async {
    final permissions = [
      Permission.location,
      Permission.notification,
      Permission.camera,
      Permission.storage,
      Permission.microphone,
    ];

    final statuses = await permissions.request();
    final allGranted = statuses.values.every((status) => status.isGranted);

    if(allGranted){
      for (var permission in permissions){
        _permissionCache[permission] = true;
      }
    }

    return allGranted;
  }

  @override
  Future<bool> checkPermissionStatus(Permission permission) async {
    if (_permissionCache[permission] != null) {
      return _permissionCache[permission]!;
    }
    final status = await permission.isGranted;
    _permissionCache[permission] = status;
    return status;
  }

  @override
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}


class PermissionHandlerService {
  final PermissionHandler _permissionHandler;

  PermissionHandlerService({PermissionHandler? permissionHandler})
      : _permissionHandler = permissionHandler ?? PermissionHandlerImpl();

  Future<bool> requestCameraPermission() {
    return _permissionHandler.requestCameraPermission();
  }

  Future<bool> requestNotificationPermission() {
    return _permissionHandler.requestNotificationPermission();
  }

  Future<bool> requestLocationPermission() {
    return _permissionHandler.requestLocationPermission();
  }

  Future<bool> requestStoragePermission() {
    return _permissionHandler.requestStoragePermission();
  }

  Future<bool> requestMicrophonePermission() {
    return _permissionHandler.requestMicrophonePermission();
  }

  Future<bool> requestMultiplePermissions() {
    return _permissionHandler.requestMultiplePermissions();
  }

  Future<bool> checkPermissionStatus(Permission permission) {
    return _permissionHandler.checkPermissionStatus(permission);
  }

  Future<void> openAppSettings() {
    return _permissionHandler.openAppSettings();
  }
}