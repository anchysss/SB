import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/book_section.dart';
import '../widgets/genre_grid.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import '../widgets/tag_section.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchBooksFromApi() async {
  const apiUrl = 'https://0qn19oc3e2.execute-api.eu-north-1.amazonaws.com/prod/getBooks';

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load books');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);  // Add const constructor

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = fetchBooksFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pastelBackground, // Assuming pastelBackground is defined in theme.dart
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Failed to load books"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No books available"));
                  }

                  final books = snapshot.data!;
                  final popular = books.where((b) => b['rate'] >= 4.7).toList();
                  final newest = books.take(5).toList();
                  final continueReading = books.reversed.take(5).toList();
                  final recommended = books.skip(3).take(5).toList();
                  final topPicks = books.where((b) => (b['tags'] ?? []).contains("bestseller")).toList();
                  
                  // Hardcoded list for "Books with Steamy Chapters"
                  final steamyBooks = books.where((b) =>
                      ['Uncharted Territory', 'Love Triangle', 'Bracni zivot', 'Matematicke muke', 'Her Strong Mafia Husband', 'A Battle of Wills']
                          .contains(b['book_name'])).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: [
                      _sectionTitle("Popular", icon: Icon(Icons.auto_awesome, color: goldColor, size: 20)),
                      BookSection(title: "", books: popular),

                      _sectionTitle("Newest", icon: Icon(Icons.fiber_new, color: pastelAccentColor, size: 20)),
                      BookSection(title: "", books: newest),

                      _sectionTitle("Top Picks for You", icon: Icon(Icons.emoji_people, color: pastelAccentColor, size: 20)),
                      BookSection(title: "", books: topPicks),

                      _sectionTitle("Genres", icon: Icon(Icons.grid_view, color: pastelAccentColor, size: 20)),
                      GenreGrid(),

                      _sectionTitle(
                        "Steamy Book Recommends",
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.recommend, color: pastelMauve, size: 24),
                            Image.asset(
                              'assets/icons/steamy_s.png',
                              width: 14,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                      BookSection(title: "", books: recommended),

                      _sectionTitle(
                        "Books with Steamy Chapters",
                        icon: Image.asset(
                          'assets/icons/steamy_s_animated.gif',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      BookSection(title: "", books: steamyBooks),

                      _sectionTitle("Tags", icon: Icon(Icons.tag, color: pastelAccentColor, size: 20)),
                      TagSection(),

                      _sectionTitle("Continue Reading", icon: Icon(Icons.menu_book, color: pastelAccentColor, size: 20)),
                      BookSection(title: "", books: continueReading),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomFooter(),
    );
  }

  Widget _sectionTitle(String title, {Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown[700],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            icon,
          ],
        ],
      ),
    );
  }
}
