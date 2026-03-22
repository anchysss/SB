import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../widgets/comment_card.dart';
import '../widgets/reply_input.dart';
import '../widgets/steamy_button.dart'; // samo dugme ostaje

class ReadChapterScreen extends StatefulWidget {
  final Map<String, dynamic> chapter;
  final String bookTitle;

  const ReadChapterScreen({
    Key? key,
    required this.chapter,
    required this.bookTitle,
  }) : super(key: key);

  @override
  _ReadChapterScreenState createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  String chapterContent = '';
  bool isLoading = true;
  bool isSteamy = false;
  bool loadingSteamy = false;

  List<dynamic> comments = [];
  final TextEditingController commentController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  String? _editingCommentId;
  String? _replyingCommentId;
  bool isPosting = false;

  final String userId = 'demo_user_123';

  // ✅ Tačni HTTP API endpointi
  final String steamyApiUrl = 'https://jywrakjzyb.execute-api.eu-north-1.amazonaws.com/markChapterSteamy';
  final String getCommentsUrl = 'https://jywrakjzyb.execute-api.eu-north-1.amazonaws.com/getComments';
  final String postCommentUrl = 'https://jywrakjzyb.execute-api.eu-north-1.amazonaws.com/postComment';
  final String replyToCommentUrl = 'https://jywrakjzyb.execute-api.eu-north-1.amazonaws.com/replyToComment';

  @override
  void initState() {
    super.initState();
    fetchChapterContent();
    fetchComments();
  }

  Future<void> fetchChapterContent() async {
    final contentUrl = widget.chapter['content_url'];

    try {
      final response = await http.get(Uri.parse(contentUrl));
      if (response.statusCode == 200) {
        setState(() {
          chapterContent = response.body;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      setState(() {
        chapterContent = 'Failed to load chapter content.';
        isLoading = false;
      });
    }
  }

  Future<void> markAsSteamy() async {
    setState(() => loadingSteamy = true);

    final response = await http.post(
      Uri.parse(steamyApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'book_id': widget.chapter['book_id'],
        'chapter_number': widget.chapter['chapter_number'],
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() => isSteamy = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as Steamy 💋')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already marked or error: ${response.body}')),
      );
    }

    setState(() => loadingSteamy = false);
  }

  Future<void> fetchComments() async {
    final uri = Uri.parse('$getCommentsUrl?book_id=${widget.chapter['book_id']}&chapter_number=${widget.chapter['chapter_number']}');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments = data['comments'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
  }

  Future<void> postComment() async {
    if (commentController.text.trim().isEmpty) return;

    setState(() => isPosting = true);

    final response = await http.post(
      Uri.parse(postCommentUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'book_id': widget.chapter['book_id'],
        'chapter_number': widget.chapter['chapter_number'],
        'user_id': userId,
        'comment_text': commentController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      commentController.clear();
      await fetchComments();
    }

    setState(() => isPosting = false);
  }

  Future<void> postReply(String commentId, String replyText) async {
    if (replyText.trim().isEmpty) return;

    final response = await http.post(
      Uri.parse(replyToCommentUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'comment_id': commentId,
        'user_id': userId,
        'reply_text': replyText.trim(),
      }),
    );

    if (response.statusCode == 200) {
      _replyController.clear();
      setState(() => _replyingCommentId = null);
      await fetchComments();
    } else {
      debugPrint('Failed to post reply: ${response.body}');
    }
  }

  Future<void> submitEditComment(String commentId) async {
    setState(() {
      _editingCommentId = null;
    });
  }

  void likeComment(String commentId) {
    debugPrint('Liked comment: $commentId');
  }

  @override
  Widget build(BuildContext context) {
    final chapterTitle = widget.chapter['chapter_title'] ?? 'Untitled Chapter';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade200,
        title: Text(widget.bookTitle),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      chapterContent,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    SteamyButton(
                      isSteamy: isSteamy,
                      loading: loadingSteamy,
                      onPressed: markAsSteamy,
                    ),

                    const SizedBox(height: 30),
                    Text(
                      'Comments 💬',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...comments.map((comment) {
                      final commentId = comment['comment_id'];

                      return CommentCard(
                        comment: comment,
                        userId: userId,
                        isEditing: _editingCommentId == commentId,
                        isReplying: _replyingCommentId == commentId,
                        editController: _editController,
                        replyController: _replyController,
                        onLike: () => likeComment(commentId),
                        onEdit: () {
                          setState(() {
                            _editingCommentId = commentId;
                            _editController.text = comment['comment_text'];
                          });
                        },
                        onSubmitEdit: () => submitEditComment(commentId),
                        onReply: () {
                          setState(() => _replyingCommentId = commentId);
                        },
                        onSendReply: () => postReply(commentId, _replyController.text),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Leave a comment...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: isPosting
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.pink),
                                onPressed: postComment,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
