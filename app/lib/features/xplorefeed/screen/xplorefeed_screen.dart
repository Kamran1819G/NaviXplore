import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navixplore/features/models/post_model.dart'; // Assuming correct path
import 'package:get/get.dart';
import 'package:navixplore/features/xplorefeed/widget/feed_widget.dart'; // Assuming correct path
import 'package:navixplore/features/xplorefeed/screen/create_post_screen.dart'; // Import CreatePostScreen
import 'package:rxdart/rxdart.dart';

class XploreFeedScreen extends StatefulWidget {
  const XploreFeedScreen({super.key});

  @override
  State<XploreFeedScreen> createState() => _XploreFeedScreenState();
}

class _XploreFeedScreenState extends State<XploreFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get FirebaseAuth instance
  final int _postsPerPage = 5;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  final RxList<PostModel> _posts = <PostModel>[].obs;
  final Map<String, PostModel> _cachedPosts = {};
  bool _isInitialLoading = true;
  String? _errorMessage;
  final _scrollController =
      ScrollController(); // ScrollController for list view

  final _loadMoreSubject = PublishSubject<void>();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
    _setupScrollListener(); // Setup scroll listener for pagination
    _loadMoreSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((_) => _loadMorePosts());
  }

  @override
  void dispose() {
    _loadMoreSubject.close();
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  Future<void> _checkAuthAndLoad() async {
    if (_auth.currentUser == null) {
      // TODO: Handle unauthenticated user (e.g., redirect to login)
      print("User not authenticated");
      setState(() {
        _isInitialLoading = false;
        _errorMessage = "User not logged in.";
      });
      return;
    }
    await _loadInitialPosts();
    _setupPostListener();
  }

  Future<void> _refreshPosts() async {
    _posts.clear();
    _cachedPosts.clear();
    _lastDocument = null;
    _isInitialLoading = true;
    await _loadInitialPosts();
  }

  Future<void> _loadInitialPosts() async {
    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      final postsQuery = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(_postsPerPage);
      final snapshot = await postsQuery.get();

      setState(() {
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          final initialPosts =
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
          _posts.addAll(initialPosts);
          _cachePosts(snapshot.docs);
        }

        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        print("Error loading data initially: $e");
        _errorMessage = "Failed to load posts";
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _setupPostListener() {
    _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _handlePostUpdates(snapshot);
    }, onError: (error) {
      print("Error in post listener: $error"); // Log listener errors
      if (_posts.isEmpty) {
        // Only set error message if initial load failed or feed is empty
        setState(() {
          _errorMessage = "Failed to load posts in real-time.";
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    });
  }

  void _cachePosts(List<DocumentSnapshot> docs) {
    for (var doc in docs) {
      final post = PostModel.fromFirestore(doc);
      _cachedPosts[post.postId!] = post;
    }
  }

  void _handlePostUpdates(QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      final post = PostModel.fromFirestore(change.doc);
      if (change.type == DocumentChangeType.added) {
        if (!_cachedPosts.containsKey(post.postId)) {
          _cachedPosts[post.postId!] = post;
          _posts.insert(0, post); // Add new posts to the top of the feed
        }
      } else if (change.type == DocumentChangeType.modified) {
        _cachedPosts[post.postId!] = post;
        final index = _posts.indexWhere((p) => p.postId == post.postId);
        if (index != -1) {
          _posts[index] = post;
        }
      } else if (change.type == DocumentChangeType.removed) {
        _cachedPosts.remove(post.postId);
        _posts.removeWhere((p) => p.postId == post.postId);
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _lastDocument == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final postsQuery = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_postsPerPage);

      final snapshot = await postsQuery.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newPosts =
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
        _posts.addAll(newPosts);
        _cachePosts(snapshot.docs);
      } else {
        _lastDocument = null; // No more posts to load
      }
    } catch (e) {
      print("Error loading more posts : $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoadingMore &&
          _lastDocument != null) {
        _loadMoreSubject.add(null); // Trigger load more when near the bottom
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Obx(
          () => // Wrap CustomScrollView with Obx to rebuild on _posts changes
              CustomScrollView(
            controller: _scrollController, // Attach scroll controller
            slivers: [
              SliverAppBar(
                pinned: true,
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
              if (_isInitialLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(child: Text(_errorMessage!)),
                )
              else if (_posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                      child: Text(
                          "No posts yet. Start following people or create a post!")),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _posts.length) {
                        return FeedWidget(_posts[index],
                            _cachedPosts[_posts[index].postId!]!);
                      } else if (_lastDocument != null && !_isLoadingMore) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )); // Loading indicator for more posts
                      } else if (_lastDocument == null &&
                          index == _posts.length &&
                          !_isInitialLoading &&
                          !_isLoadingMore &&
                          _posts.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                              child: Text(
                                  "No more posts to load.")), // Reached end
                        );
                      }
                      return null; // Should not reach here, but for safety
                    },
                    childCount: _posts.length +
                        (_lastDocument != null
                            ? 1
                            : (_posts.isNotEmpty &&
                                    !_isInitialLoading &&
                                    !_isLoadingMore
                                ? 1
                                : 0)), // Add 1 for loading/end indicator
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const CreatePostScreen()), // Navigate to CreatePostScreen
          );
        },
        child: const Icon(Icons.add_photo_alternate),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
