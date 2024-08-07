import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String? location;
  final String imageUrl;
  final List<String> likeIds;
  final String caption;
  final Timestamp createdAt;
  final int commentCount;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    this.location,
    required this.imageUrl,
    required this.likeIds,
    required this.caption,
    required this.createdAt,
    required this.commentCount,
  });

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      location: data['location'],
      imageUrl: data['imageUrl'] ?? '',
      likeIds: List<String>.from(data['likeIds'] ?? []),
      caption: data['caption'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'location': location,
      'imageUrl': imageUrl,
      'likeIds': likeIds,
      'caption': caption,
      'createdAt': createdAt,
      'commentCount': commentCount,
    };
  }
}
