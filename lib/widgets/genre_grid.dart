import 'package:flutter/material.dart';
import '../theme.dart';

class GenreGrid extends StatelessWidget {
  final List<Map<String, dynamic>> genres = [
    {"label": "Romance", "icon": Icons.favorite_border, "color": pastelPink},
    {"label": "Erotica", "icon": Icons.local_fire_department, "color": pastelMauve},
    {"label": "History", "icon": Icons.menu_book, "color": pastelPeach},
    {"label": "Mystery", "icon": Icons.visibility_off_outlined, "color": pastelLavender},
    {"label": "Dark Romance", "icon": Icons.nights_stay, "color": pastelGrey},
    {"label": "Young Adults", "icon": Icons.emoji_people, "color": pastelMint},
    {"label": "Fantasy", "icon": Icons.auto_awesome, "color": Color(0xFFE0BBE4)}, 
    {"label": "Paranormal", "icon": Icons.visibility, "color": Color(0xFFB5EAD7)},
    {"label": "Comedy", "icon": Icons.sentiment_very_satisfied, "color": Color(0xFFFFDAC1)},
    {"label": "Horror", "icon": Icons.warning_amber, "color": Color(0xFFFF9AA2)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // Visina za 2 reda
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: (genres.length / 2).ceil(),
          itemBuilder: (context, columnIndex) {
            final int firstIndex = columnIndex * 2;
            final int secondIndex = firstIndex + 1;
            final genre1 = genres[firstIndex];
            final genre2 = secondIndex < genres.length ? genres[secondIndex] : null;

            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                children: [
                  _buildGenreBox(genre1),
                  const SizedBox(height: 12),
                  if (genre2 != null) _buildGenreBox(genre2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenreBox(Map<String, dynamic> genre) {
    return Container(
      width: 140,
      height: 60,
      decoration: BoxDecoration(
        color: genre['color'],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(genre['icon'], size: 20, color: Colors.brown[800]),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                genre['label'],
                style: TextStyle(
                  color: Colors.brown[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
