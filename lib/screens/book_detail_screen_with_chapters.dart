import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'ReadChapterScreen.dart';

class BookDetailScreenWithChapters extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreenWithChapters({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailScreenWithChapters> createState() => _BookDetailScreenWithChaptersState();
}

class _BookDetailScreenWithChaptersState extends State<BookDetailScreenWithChapters>
    with TickerProviderStateMixin {
  List<dynamic> chapters = [];
  bool isLoading = true;
  Map<int, int> countdowns = {};
  double steamyLevel = 0.0;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchChapters();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchChapters() async {
    final bookId = widget.book['book_id'];
    final url = 'https://47ub1oiqe6.execute-api.eu-north-1.amazonaws.com/prod/getChapters?book_id=$bookId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['chapters'] ?? [];

        data.sort((a, b) {
          final aNum = int.tryParse(a['chapter_number']?.toString() ?? '0') ?? 0;
          final bNum = int.tryParse(b['chapter_number']?.toString() ?? '0') ?? 0;
          return aNum.compareTo(bNum);
        });

        setState(() {
          chapters = data;
          isLoading = false;
          calculateSteamyLevel(data);
        });
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      print('Error fetching chapters: $e');
      setState(() => isLoading = false);
    }
  }

  void calculateSteamyLevel(List<dynamic> chapters) {
    int total = chapters.length;
    int steamyCount = 0;

    for (var chapter in chapters) {
      int s = int.tryParse(chapter['steamy_votes']?.toString() ?? '0') ?? 0;
      if (s > 0) steamyCount++;
    }

    if (total > 0) {
      setState(() {
        steamyLevel = steamyCount / total;
      });
    }
  }

  Widget buildSteamyIcon() {
    return Image.asset(
      'assets/icons/kiss_animated.gif',
      height: 32,
      width: 32,
      fit: BoxFit.cover,
    );
  }

  Widget buildAnimatedIcon(IconData icon, Color color) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final title = book['book_name'];
    final author = book['author_name'];
    final cover = book['cover_image'];
    final genre = (book['genre'] is List) ? (book['genre'] as List).join(', ') : book['genre'] ?? '';
    final summary = book['short_summary'] ?? '';
    final rating = double.tryParse(book['rate']?.toString() ?? '0') ?? 0.0;
    final ratingCount = int.tryParse(book['rating_count']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: pastelBackground,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: pastelCardColor,
                      border: Border.all(color: pastelAccentColor.withOpacity(0.4), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        cover ?? '',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title ?? 'Book Title',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                            const SizedBox(height: 4),
                            Text("by $author", style: const TextStyle(fontSize: 16, color: Colors.brown)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 24),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.brown)),
                              const SizedBox(width: 6),
                              Text("($ratingCount votes)", style: const TextStyle(fontSize: 13, color: Colors.brown)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildSteamyIcon(),
                              const SizedBox(width: 6),
                              const Text("Steamy", style: TextStyle(fontSize: 13, color: Colors.brown)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (genre.isNotEmpty) Chip(label: Text(genre)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (chapters.isNotEmpty) {
                        final firstChapter = chapters.first;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReadChapterScreen(
                              chapter: firstChapter,
                              bookTitle: widget.book['book_name'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please wait, chapters are still loading.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelMauve,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Start Reading", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  if (summary.isNotEmpty)
                    Text(summary, style: const TextStyle(fontSize: 14, color: Colors.brown)),
                  const SizedBox(height: 24),
                  const Text("Chapters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (chapters.isEmpty)
                    const Text("No chapters found.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        final chapterTitle = chapter['chapter_title'] ?? 'Untitled';
                        final chapterNumber = int.tryParse(chapter['chapter_number']?.toString() ?? '0') ?? index + 1;
                        final price = int.tryParse(chapter['price_to_unlock']?.toString() ?? '0') ?? 0;
                        final ads = int.tryParse(chapter['reward_ads_count']?.toString() ?? '0') ?? 0;
                        final timerSec = int.tryParse(chapter['timer_seconds']?.toString() ?? '0') ?? 0;

                        String subtitleText = price == 0 ? "Free to read" : (chapter['is_unlocked'] == true ? "Unlocked" : "To continue reading");

                        String timeText = timerSec >= 3600 ? "${(timerSec / 3600).toStringAsFixed(1)} h" : "${(timerSec / 60).round()} min";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pastelCardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: pastelAccentColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  buildAnimatedIcon(
                                    price == 0
                                        ? Icons.play_circle_fill
                                        : (chapter['is_unlocked'] == true ? Icons.lock_open : Icons.lock),
                                    price == 0
                                        ? Colors.green
                                        : (chapter['is_unlocked'] == true ? Colors.blue : Colors.redAccent),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Chapter $chapterNumber",
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                                        const SizedBox(height: 2),
                                        Text(chapterTitle, style: const TextStyle(fontSize: 14, color: Colors.brown)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(subtitleText, style: TextStyle(fontSize: 13, color: Colors.brown[400])),
                              if (price > 0 && chapter['is_unlocked'] != true) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        buildAnimatedIcon(Icons.timer, pastelMauve),
                                        const SizedBox(height: 4),
                                        Text("Wait $timeText", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        buildAnimatedIcon(Icons.ondemand_video, pastelRose),
                                        const SizedBox(height: 4),
                                        Text("Watch $ads ad(s)", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        buildAnimatedIcon(Icons.monetization_on, goldColor),
                                        const SizedBox(height: 4),
                                        Text("Pay $price coin(s)", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomFooter(),
    );
  }
}
