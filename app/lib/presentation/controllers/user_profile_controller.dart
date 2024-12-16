import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class UserProfileController extends GetxController {
  final String userId;

  UserProfileController({required this.userId});

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final _user = Rxn<UserModel>();
  UserModel? get user => _user.value;

  final _posts = <PostModel>[].obs;
  List<PostModel> get posts => _posts;

  final _isFollowing = false.obs;
  bool get isFollowing => _isFollowing.value;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();

  }

  Future<void> _loadProfileData() async{
    _isLoading.value = true;
    User? currentUser = _auth.currentUser;
    try{

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _user.value = UserModel.fromFirestore(userDoc);
      }else {
        _user.value = null;
      }

      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _posts.assignAll(postsSnapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
      if(currentUser != null && currentUser.uid != userId){
        _isFollowing.value = await isFollowingUser(currentUser.uid);
      }
    }catch(e){
      print("Error loading user profile : $e");
    } finally {
      _isLoading.value = false;
    }
  }


  Future<bool> isFollowingUser(String currentUserId) async {
    try {
      final doc = await _firestore
          .collection('following')
          .doc(currentUserId)
          .collection('userFollowing')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking following status: $e');
      return false;
    }
  }

  Future<void> followUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return; // Handle case when no user is signed in
    try {
      final userFollowingRef = _firestore
          .collection('following')
          .doc(currentUser.uid)
          .collection('userFollowing')
          .doc(userId);

      final userFollowerRef = _firestore
          .collection('followers')
          .doc(userId)
          .collection('userFollowers')
          .doc(currentUser.uid);

      await _firestore.runTransaction((transaction) async{
        transaction.set(userFollowingRef, {});
        transaction.set(userFollowerRef, {});

      });
      _isFollowing.value = true;
    } catch(e){
      print('Error follow user $e');
    }

  }

  Future<void> unfollowUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final userFollowingRef = _firestore
          .collection('following')
          .doc(currentUser.uid)
          .collection('userFollowing')
          .doc(userId);

      final userFollowerRef = _firestore
          .collection('followers')
          .doc(userId)
          .collection('userFollowers')
          .doc(currentUser.uid);

      await _firestore.runTransaction((transaction) async{
        transaction.delete(userFollowingRef);
        transaction.delete(userFollowerRef);
      });
      _isFollowing.value = false;
    }catch(e){
      print('error unfollow user $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
    _user.close();
    _posts.close();
    _isFollowing.close();

  }

}