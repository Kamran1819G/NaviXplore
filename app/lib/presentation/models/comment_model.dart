import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String text;
  final Timestamp createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
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
