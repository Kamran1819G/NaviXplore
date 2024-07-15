import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of a collection
  Stream<QuerySnapshot> getCollection({required String collection}) {
    return _firestore.collection(collection).snapshots();
  }

  // Get a sorted collection
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

  // Get a single document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Get documents with multiple filters
  Future<QuerySnapshot> getDocumentsWithFilters({
    required String collection,
    required List<Map<String, dynamic>> filters,
  }) async {
    Query query = _firestore.collection(collection);
    for (Map<String, dynamic> filter in filters) {
      query = query.where(filter['field'], isEqualTo: filter['value']);
    }
    return await query.get();
  }

  // Add a new document
  Future<DocumentReference> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    return await _firestore.collection(collection).add(data);
  }

  // Update an existing document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Get documents with pagination
  Future<QuerySnapshot> getDocumentsWithPagination({
    required String collection,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore.collection(collection).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return await query.get();
  }

  // Get documents within a specific range
  Future<QuerySnapshot> getDocumentsInRange({
    required String collection,
    required String field,
    required dynamic start,
    required dynamic end,
  }) async {
    return await _firestore
        .collection(collection)
        .where(field, isGreaterThanOrEqualTo: start)
        .where(field, isLessThanOrEqualTo: end)
        .get();
  }

  // Perform a transaction
  Future<void> performTransaction(Function(Transaction) updateFunction) async {
    await _firestore.runTransaction((Transaction transaction) async {
      await updateFunction(transaction);
    });
  }

  // Get a subcollection of a document
  Stream<QuerySnapshot> getSubcollection({
    required String collection,
    required String docId,
    required String subcollection,
  }) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .snapshots();
  }

  // Listen to real-time updates on a single document
  Stream<DocumentSnapshot> listenToDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }
}