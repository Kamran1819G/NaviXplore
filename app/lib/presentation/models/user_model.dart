import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String username;
  String displayName;
  String? profileImage;
  String? bio;
  int postCount;
  int followerCount;
  int followingCount;

  UserModel({
    this.uid,
    required this.username,
    required this.displayName,
    this.profileImage,
    this.bio,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImage: data['profileImage'],
      bio: data['bio'],
      postCount: data['postCount'] ?? 0,
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'displayName': displayName,
        'profileImage': profileImage,
        'bio': bio,
        'postCount': postCount,
        'followerCount': followerCount,
        'followingCount': followingCount,
      };
}
