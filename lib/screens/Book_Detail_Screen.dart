import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SimpleReadChapterScreen extends StatefulWidget {
  final Map<String, dynamic> chapter;
  final String bookTitle;

  const SimpleReadChapterScreen({required this.chapter, required this.bookTitle, Key? key}) : super(key: key);

  @override
  _SimpleReadChapterScreenState createState() => _SimpleReadChapterScreenState();
}

class _SimpleReadChapterScreenState extends State<SimpleReadChapterScreen> {
  String chapterContent = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChapterContent();
  }

  Future<void> fetchChapterContent() async {
    final chapter = widget.chapter;
    final contentUrl = chapter['content_url'];

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

  @override
  Widget build(BuildContext context) {
    final chapterTitle = widget.chapter['chapter_title'] ?? 'Chapter';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[100],
        iconTheme: const IconThemeData(color: Colors.brown),
        title: Text(
          widget.bookTitle,
          style: const TextStyle(color: Colors.brown),
        ),
      ),
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                    const SizedBox(height: 16),
                    Text(
                      chapterContent,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
