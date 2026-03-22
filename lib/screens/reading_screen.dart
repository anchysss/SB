import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';

class ReadingScreen extends StatefulWidget {
  final String bookId;
  final int chapterNumber;

  const ReadingScreen({super.key, required this.bookId, required this.chapterNumber});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  Map<String, dynamic>? chapter;
  bool isLoading = true;
  bool markedSteamy = false;
  final commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    fetchChapter();
    fetchComments();
  }

  Future<void> fetchChapter() async {
    final url =
        'https://47ub1oiqe6.execute-api.eu-north-1.amazonaws.com/prod/getChapters?book_id=${widget.bookId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final target = data.firstWhere(
          (c) => int.tryParse(c['chapter_number'].toString()) == widget.chapterNumber,
          orElse: () => null,
        );

        if (target != null) {
          setState(() {
            chapter = target;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print('Error fetching chapter: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchComments() async {
    // MOCK DATA for now
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      comments = [
        {
          'id': 1,
          'user': 'LanaM',
          'text': 'Omg this chapter was 🔥🔥🔥',
          'likes': 3,
          'isOwn': false,
          'replies': [],
        },
        {
          'id': 2,
          'user': 'AnaSt',
          'text': "Can't wait for the next one!",
          'likes': 1,
          'isOwn': true,
          'replies': [
            {'user': 'Kiki', 'text': 'Me too! 😍'}
          ],
        },
      ];
    });
  }

  void submitComment() {
    if (commentController.text.trim().isEmpty) return;
    setState(() {
      comments.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'user': 'You',
        'text': commentController.text.trim(),
        'likes': 0,
        'isOwn': true,
        'replies': [],
      });
      commentController.clear();
    });
  }

  void toggleSteamy() {
    setState(() {
      markedSteamy = !markedSteamy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelBackground,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(showBackButton: true),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chapter == null
                      ? const Center(child: Text("Chapter not found."))
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                              "Chapter ${chapter!['chapter_number']}: ${chapter!['chapter_title'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              chapter!['content'] ?? 'No content available.',
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/lips_animated.gif',
                                    height: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Was this chapter steamy?",
                                      style: TextStyle(color: Colors.brown[600])),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: toggleSteamy,
                                    icon: Icon(
                                      markedSteamy ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                    label: Text(markedSteamy ? "Marked as Steamy" : "Mark as Steamy"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: pastelRose,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text("Comments",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Leave a comment...",
                                fillColor: pastelCardColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: submitComment,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...comments.map((c) => buildCommentTile(c)).toList(),
                          ],
                        ),
            ),
            CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget buildCommentTile(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pastelCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pastelAccentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment['user'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 4),
          Text(comment['text'], style: const TextStyle(color: Colors.brown)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                onPressed: () {},
              ),
              Text("${comment['likes']}"),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                child: const Text("Reply"),
              ),
              if (comment['isOwn'])
                TextButton(
                  onPressed: () {
                    commentController.text = comment['text'];
                  },
                  child: const Text("Edit"),
                ),
            ],
          ),
          if (comment['replies'] != null)
            ...comment['replies'].map<Widget>((reply) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 6),
                  child: Text(
                    "${reply['user']}: ${reply['text']}",
                    style: const TextStyle(color: Colors.brown),
                  ),
                )),
        ],
      ),
    );
  }
}
