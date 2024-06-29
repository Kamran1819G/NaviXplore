import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService{
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({required String path, required File file}) async {
    final ref = _storage.ref(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile({required String path}) async {
    final ref = _storage.ref(path);
    await ref.delete();
  }
}