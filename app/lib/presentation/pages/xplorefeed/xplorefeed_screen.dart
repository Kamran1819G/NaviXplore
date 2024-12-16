import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navixplore/presentation/models/post_model.dart';
import 'package:get/get.dart';
import 'package:navixplore/presentation/pages/xplorefeed/feed_widget.dart';
import 'package:rxdart/rxdart.dart';

class XploreFeedScreen extends StatefulWidget {
  const XploreFeedScreen({super.key});

  @override
  State<XploreFeedScreen> createState() => _XploreFeedScreenState();
}

class _XploreFeedScreenState extends State<XploreFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _postsPerPage = 5;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  final RxList<PostModel> _posts = <PostModel>[].obs;
  final Map<String, PostModel> _cachedPosts = {};
  bool _isInitialLoading = true;
  String? _errorMessage;


  // Add a Subject to debounce
  final _loadMoreSubject = PublishSubject<void>();

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
    _setupPostListener();

    // Subscribe to the subject
    _loadMoreSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((_) => _loadMorePosts());
  }

  @override
  void dispose() {
    _loadMoreSubject.close();
    super.dispose();
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
          final initialPosts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
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
          _posts.add(post);
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
        _lastDocument = null;
      }
    } catch (e) {
      print("Error loading more posts : $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: CustomScrollView(
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
            else
              Obx(() =>
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index < _posts.length) {
                          return FeedWidget(
                              _posts[index], _cachedPosts[_posts[index].postId!]!);
                        } else if (_lastDocument != null && !_isLoadingMore) {
                          _loadMoreSubject.add(null);
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      childCount: _posts.length + (_lastDocument == null ? 0 : 1),
                    ),
                  ),),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new post creation
        },
        child: const Icon(Icons.add_photo_alternate),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}