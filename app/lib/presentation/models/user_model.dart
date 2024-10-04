import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final String profileImage;

  UserModel({
    this.id,
    required this.username,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.profileImage,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postCount: data['postCount'] ?? 0,
      profileImage: data['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'profileImage': profileImage,
    };
  }
}
