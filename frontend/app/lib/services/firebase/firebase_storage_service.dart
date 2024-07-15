import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile({required String path, required File file}) async {
    final ref = _storage.ref(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile({required String path}) async {
    final ref = _storage.ref(path);
    await ref.delete();
  }

  // Upload data as a string to Firebase Storage
  Future<String> uploadString({required String path, required String data, String format = 'raw'}) async {
    final ref = _storage.ref(path);
    await ref.putString(data, format: PutStringFormat.raw);
    return await ref.getDownloadURL();
  }

  // Download a file from Firebase Storage
  Future<File> downloadFile({required String path, required String localPath}) async {
    final ref = _storage.ref(path);
    final file = File(localPath);
    await ref.writeToFile(file);
    return file;
  }

  // Get metadata of a file
  Future<FullMetadata> getMetadata({required String path}) async {
    final ref = _storage.ref(path);
    return await ref.getMetadata();
  }

  // Update metadata of a file
  Future<FullMetadata> updateMetadata({required String path, required SettableMetadata metadata}) async {
    final ref = _storage.ref(path);
    return await ref.updateMetadata(metadata);
  }

  // List all files in a directory
  Future<List<Reference>> listFiles({required String path}) async {
    final ref = _storage.ref(path);
    final result = await ref.listAll();
    return result.items;
  }

  // Get download URL of a file
  Future<String> getDownloadURL({required String path}) async {
    final ref = _storage.ref(path);
    return await ref.getDownloadURL();
  }

  // Copy a file to a new location
  Future<String> copyFile({required String sourcePath, required String destinationPath}) async {
    final sourceRef = _storage.ref(sourcePath);
    final destRef = _storage.ref(destinationPath);
    await destRef.putString(await sourceRef.getData() as String);
    return await destRef.getDownloadURL();
  }

  // Move a file to a new location
  Future<String> moveFile({required String sourcePath, required String destinationPath}) async {
    final newUrl = await copyFile(sourcePath: sourcePath, destinationPath: destinationPath);
    await deleteFile(path: sourcePath);
    return newUrl;
  }

  // Check if a file exists
  Future<bool> fileExists({required String path}) async {
    final ref = _storage.ref(path);
    try {
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}