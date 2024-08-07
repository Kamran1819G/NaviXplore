import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navixplore/domain/entities/post_model.dart';
import 'package:navixplore/domain/entities/comment_model.dart';
import 'package:navixplore/presentation/pages/profile/user_profile_screen.dart';

class XploreFeedScreen extends StatelessWidget {
  const XploreFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<PostModel> dummyPosts = [
      PostModel(
        id: 'asdjklsajdlkadjfkldsafj',
        userId: 'user1',
        username: 'John Doe',
        userPhotoUrl: 'https://example.com/profile1.jpg',
        location: 'New York',
        imageUrl: 'https://placeholder.com/300',
        likeIds: ['user1', 'user2'],
        caption: 'Beautiful day in NYC!',
        createdAt: Timestamp.now(),
        commentCount: 0,
      ),
      PostModel(
        id: 'asdjksafddsafsadlkadjfkldsafj',
        userId: 'user2',
        username: 'Jane Smith',
        userPhotoUrl: 'https://example.com/profile2.jpg',
        location: 'Los Angeles',
        imageUrl: 'https://placeholder.com/300',
        likeIds: ['user3'],
        caption: 'Sunset at the beach',
        createdAt: Timestamp.now(),
        commentCount: 0,
      ),
      PostModel(
        id: 'fdsgfdgdsfljgsafj',
        userId: 'user3',
        username: 'Mike Johnson',
        userPhotoUrl: 'https://example.com/profile3.jpg',
        location: 'Chicago',
        imageUrl: 'https://placeholder.com/300',
        likeIds: [],
        caption: 'City lights',
        createdAt: Timestamp.now(),
        commentCount: 0,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              "Xplore Feed",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => FeedWidget(dummyPosts[index]),
              childCount: dummyPosts.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new post creation
        },
        child: Icon(Icons.add_photo_alternate),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class FeedWidget extends StatefulWidget {
  final PostModel postData;

  FeedWidget(this.postData, {Key? key}) : super(key: key);

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget>
    with SingleTickerProviderStateMixin {
  bool isAnimating = false;
  String user = 'currentUser'; // Dummy user ID
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(_controller);
  }

  void _likePost() {
    setState(() {
      if (widget.postData.likeIds.contains(user)) {
        widget.postData.likeIds.remove(user);
      } else {
        widget.postData.likeIds.add(user);
        _controller.forward().then((_) => _controller.reverse());
      }
      isAnimating = true;
    });
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: _navigateToUserProfile,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.postData.userPhotoUrl),
              ),
            ),
            title: GestureDetector(
              onTap: _navigateToUserProfile,
              child: Text(
                widget.postData.username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(widget.postData.location ?? ''),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Implement post options
              },
            ),
          ),
          GestureDetector(
            onDoubleTap: _likePost,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.postData.imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: isAnimating ? 1 : 0,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Icon(
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
            padding: EdgeInsets.all(16),
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
                          widget.postData.likeIds.contains(user)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.postData.likeIds.contains(user)
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.2,
                            maxChildSize: 0.95,
                            expand: false,
                            builder: (_, controller) => Comment(
                                'post', widget.postData.id,
                                scrollController: controller),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat_bubble_outline),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        // TODO: Implement bookmark functionality
                      },
                      icon: Icon(Icons.bookmark_border),
                    ),
                  ],
                ),
                Text(
                  '${widget.postData.likeIds.length} likes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: widget.postData.username + ' ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.postData.caption),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat.yMMMd()
                      .add_jm()
                      .format(widget.postData.createdAt.toDate()),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatefulWidget {
  final String type;
  final String postId;
  final ScrollController scrollController;

  Comment(this.type, this.postId, {Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final comment = TextEditingController();
  bool isLoading = false;
  List<CommentModel> comments = [];

  @override
  void initState() {
    super.initState();
    // Populate with dummy data
    comments = [
      // ... (keep your existing dummy comments)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemBuilder: (context, index) {
                return comment_item(comments[index]);
              },
              itemCount: comments.length,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: comment,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    if (comment.text.isNotEmpty) {
                      comments.add(CommentModel(
                        id: 'newComment${comments.length + 1}',
                        postId: widget.postId,
                        userId: 'currentUser',
                        username: 'CurrentUser',
                        userPhotoUrl: 'https://example.com/profile3.jpg',
                        text: comment.text,
                        createdAt: Timestamp.now(),
                      ));
                    }
                    setState(() {
                      isLoading = false;
                      comment.clear();
                    });
                  },
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget comment_item(CommentModel commentData) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(commentData.userPhotoUrl),
      ),
      title: Text(
        commentData.username,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(commentData.text),
      trailing: Text(
        DateFormat.yMMMd().add_jm().format(commentData.createdAt.toDate()),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool iconLike;

  const LikeAnimation({
    Key? key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.iconLike = false,
  }) : super(key: key);

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    );
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  startAnimation() async {
    if (widget.isAnimating || widget.iconLike) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(
        const Duration(milliseconds: 200),
      );
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
