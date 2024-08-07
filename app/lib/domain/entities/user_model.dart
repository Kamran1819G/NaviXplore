import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String photoUrl;
  final String username;
  final List<String> followerIds;
  final List<String> followingIds;
  final int postCount;
  final Timestamp createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.photoUrl,
    required this.username,
    required this.followerIds,
    required this.followingIds,
    required this.postCount,
    required this.createdAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      username: data['username'] ?? '',
      followerIds: List<String>.from(data['followerIds'] ?? []),
      followingIds: List<String>.from(data['followingIds'] ?? []),
      postCount: data['postCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'photoUrl': photoUrl,
      'username': username,
      'followerIds': followerIds,
      'followingIds': followingIds,
      'postCount': postCount,
      'createdAt': createdAt,
    };
  }
}