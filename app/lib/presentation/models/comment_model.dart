import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id; // Id can be null while creating new comment
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String text;
  final Timestamp createdAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(
      DocumentSnapshot doc, String documentId) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: documentId, // Use the document ID as id
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': createdAt,
    };
  }
}