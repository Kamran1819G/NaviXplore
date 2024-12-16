import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navixplore/presentation/models/comment_model.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<CommentModel>> _commentsStream;

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
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
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
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (comment.text.isNotEmpty) {
                      final newComment = CommentModel(
                        id: null,
                        postId: widget.postId,
                        userId: 'currentUser',
                        username: 'CurrentUser',
                        userPhotoUrl: 'https://example.com/profile3.jpg',
                        text: comment.text,
                        createdAt: Timestamp.now(),
                      );
                      _firestore.collection('comments').add(newComment.toFirestore());
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
        backgroundImage: NetworkImage(commentData.userPhotoUrl!),
      ),
      title: Text(
        commentData.username!,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(commentData.text!),
      trailing: Text(
        DateFormat.yMMMd().add_jm().format(commentData.createdAt!.toDate()),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}