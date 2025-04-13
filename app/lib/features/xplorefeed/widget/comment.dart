import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navixplore/features/models/comment_model.dart'; // Assuming correct path

class Comment extends StatefulWidget {
  final String type;
  final String postId;
  final ScrollController scrollController;

  const Comment(this.type, this.postId,
      {Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final commentController = TextEditingController(); // Renamed for clarity
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<CommentModel>> _commentsStream;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get FirebaseAuth instance

  @override
  void initState() {
    super.initState();
    _commentsStream = _firestore
        .collection('comments')
        .where('postId', isEqualTo: widget.postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc, doc.id))
          .toList();
    });
  }

  @override
  void dispose() {
    commentController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  controller: widget.scrollController,
                  itemBuilder: (context, index) {
                    return comment_item(comments[index]);
                  },
                  itemCount: comments.length,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    if (commentController.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      User? user = _auth.currentUser; // Get current user
                      if (user != null) {
                        DocumentSnapshot userDoc = await _firestore
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        Map<String, dynamic> userData =
                            userDoc.data() as Map<String, dynamic>;

                        final newComment = CommentModel(
                          postId: widget.postId,
                          userId: user.uid, // Use current user's UID
                          username: userData['username'] ??
                              'Anonymous', // Get username from user doc
                          userPhotoUrl: userData['userPhotoUrl'] ??
                              '', // Get photo URL from user doc
                          text: commentController.text,
                          createdAt: Timestamp.now(),
                        );

                        await _firestore
                            .collection('comments')
                            .add(newComment.toFirestore());

                        // Update comment count in the post (Optimistic update - consider error handling)
                        DocumentReference postRef =
                            _firestore.collection('posts').doc(widget.postId);
                        await _firestore.runTransaction((transaction) async {
                          DocumentSnapshot snapshot =
                              await transaction.get(postRef);
                          if (!snapshot.exists) {
                            throw Exception("Post does not exist!");
                          }
                          int newCommentCount = (snapshot.data()
                                  as Map<String, dynamic>)['commentCount'] ??
                              0;
                          newCommentCount++;
                          transaction.update(
                              postRef, {'commentCount': newCommentCount});
                        });
                      }

                      setState(() {
                        isLoading = false;
                        commentController.clear();
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
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
        backgroundImage: NetworkImage(commentData.userPhotoUrl!),
      ),
      title: Text(
        commentData.username!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(commentData.text!),
      trailing: Text(
        DateFormat.yMMMd().add_jm().format(commentData.createdAt!.toDate()),
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}
