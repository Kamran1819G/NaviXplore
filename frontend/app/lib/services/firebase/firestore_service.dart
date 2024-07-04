import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCollection({required String collection}) {
    return _firestore.collection(collection).snapshots();
  }

  Future<QuerySnapshot> getSortedCollection({
    required String collection,
    required String orderBy,
    bool descending = false,
  }) {
    return _firestore
        .collection(collection)
        .orderBy(orderBy, descending: descending)
        .get();
  }

  Future<DocumentSnapshot> getDocument(
      {required String collection, required String docId}) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getDocumentWithMultipleFilter({
    required String collection,
    required List<Map<String, dynamic>> filters,
  }) async {
    Query query = _firestore.collection(collection);
    for (Map<String, dynamic> filter in filters) {
      query = query.where(filter['field'], isEqualTo: filter['value']);
    }
    return await query.get();
  }

  Future<void> addData(
      {required String collection, required Map<String, dynamic> data}) async {
    await _firestore.collection(collection).add(data);
  }

  Future<void> updateData(
      {required String collection,
      required String docId,
      required Map<String, dynamic> data}) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteData(
      {required String collection, required String docId}) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
}
