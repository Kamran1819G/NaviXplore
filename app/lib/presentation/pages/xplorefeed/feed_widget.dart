import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navixplore/presentation/models/post_model.dart';
import 'package:navixplore/presentation/pages/profile/user_profile_screen.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/pages/xplorefeed/comment.dart';
import 'package:navixplore/presentation/pages/xplorefeed/like_animation.dart';

class FeedWidget extends StatefulWidget {
  final PostModel postData;
  final PostModel cachedData;

  const FeedWidget(this.postData, this.cachedData, {Key? key}) : super(key: key);

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget>
    with SingleTickerProviderStateMixin {
  bool isAnimating = false;
  final String user = 'currentUser'; // Use final instead of late for constants
  late AnimationController _controller;
  late Animation<double> _animation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PostModel _currentPost;
  late Future<void> _loadPostDataFuture;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.cachedData;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(_controller);
    _loadPostDataFuture = _loadPostData();
  }

  Future<void> _loadPostData() async {
    if (widget.postData.username == null || widget.postData.userPhotoUrl == null) {
      final userDoc =
      await _firestore.collection('users').doc(widget.postData.userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _currentPost = PostModel(
            postId: _currentPost.postId,
            userId: _currentPost.userId,
            username: userData['username'],
            userPhotoUrl: userData['userPhotoUrl'],
            location: _currentPost.location,
            imageUrl: _currentPost.imageUrl,
            likeIds: _currentPost.likeIds,
            caption: _currentPost.caption,
            createdAt: _currentPost.createdAt,
            commentCount: _currentPost.commentCount);
      }
    }
  }

  void _likePost() async {
    final postRef = _firestore.collection('posts').doc(widget.postData.postId);
    final likeIds = List<String>.from(_currentPost.likeIds);
    bool isLiked = likeIds.contains(user);
    if (isLiked) {
      likeIds.remove(user);
    } else {
      likeIds.add(user);
      _controller.forward().then((_) => _controller.reverse());
    }
    await postRef.update({'likeIds': likeIds});
    _updateCachedPost(likeIds);
    setState(() {
      isAnimating = true;
    });

    Get.snackbar(
        isLiked ? "Unlike" : "Like",
        isLiked ? "You unliked the post" : "You liked the post",
        duration: const Duration(milliseconds: 500),
        snackPosition: SnackPosition.BOTTOM);
  }

  void _updateCachedPost(List<String> likeIds) {
    _currentPost = PostModel(
        postId: _currentPost.postId,
        userId: _currentPost.userId,
        username: _currentPost.username,
        userPhotoUrl: _currentPost.userPhotoUrl,
        location: _currentPost.location,
        imageUrl: _currentPost.imageUrl,
        likeIds: likeIds,
        caption: _currentPost.caption,
        createdAt: _currentPost.createdAt,
        commentCount: _currentPost.commentCount);
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserProfileScreen(
              userId: widget.postData.userId, isMyProfile: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadPostDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container( // Changed Card to Container
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,  // Use theme color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [   // Modern shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0), // Added padding
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _navigateToUserProfile,
                        child: CircleAvatar(
                          radius: 20, // Slightly reduced size
                          backgroundImage: _currentPost.userPhotoUrl != null
                              ? NetworkImage(_currentPost.userPhotoUrl!)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToUserProfile,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPost.username!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                widget.postData.location ?? '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12), // Adjusted style
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // TODO: Implement post options
                        },
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onDoubleTap: _likePost,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(
                            bottom: Radius.circular(0), top: Radius.circular(0)), // Only rounded bottom
                        child: Image.network(
                          widget.postData.imageUrl!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isAnimating ? 1 : 0,
                        child: ScaleTransition(
                          scale: _animation,
                          child: const Icon(
                            Icons.favorite,
                            size: 100,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LikeAnimation(
                            isAnimating: isAnimating,
                            onEnd: () {
                              setState(() {
                                isAnimating = false;
                              });
                            },
                            child: IconButton(
                              onPressed: _likePost,
                              icon: Icon(
                                _currentPost.likeIds.contains(user)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _currentPost.likeIds.contains(user)
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0)),
                                ),
                                builder: (context) => DraggableScrollableSheet(
                                  initialChildSize: 0.6,
                                  minChildSize: 0.2,
                                  maxChildSize: 0.95,
                                  expand: false,
                                  builder: (_, controller) => Comment(
                                      'post', widget.postData.postId!,
                                      scrollController: controller),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                          ),
                          const Spacer(), // Spacer pushes the bookmark icon to end
                          IconButton(
                            onPressed: () {
                              // TODO: Implement bookmark functionality
                            },
                            icon: const Icon(Icons.bookmark_border),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentPost.likeIds.length} likes',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: '${_currentPost.username!} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: widget.postData.caption),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.postData.createdAt!.toDate()), // Corrected Line
                        style: TextStyle(color: Colors.grey[600], fontSize: 12), // Adjusted style
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}