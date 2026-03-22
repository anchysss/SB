import 'package:flutter/material.dart';
import '../theme.dart';

class TagSection extends StatelessWidget {
  static const List<Map<String, dynamic>> tags = [
    {"label": "Alpha Male", "color": pastelPeach},
    {"label": "Bad Boy", "color": pastelMauve},
    {"label": "Bad Girl", "color": pastelLavender},
    {"label": "Virgin", "color": pastelMint},
    {"label": "Mafia", "color": pastelGrey},
    {"label": "CEO / Boss", "color": pastelPink},
    {"label": "Billionaire", "color": pastelLavender},
    {"label": "Bodyguard", "color": pastelMauve},
    {"label": "Single Dad", "color": pastelPeach},
    {"label": "Celebrity", "color": pastelMint},
    {"label": "Doctor", "color": pastelGrey},
    {"label": "Royalty", "color": pastelPink},
    {"label": "One-Night Stand", "color": pastelLavender},
    {"label": "Best Friends", "color": pastelPeach},
    {"label": "Enemies to Lovers", "color": pastelMauve},
    {"label": "Fake Dating", "color": pastelMint},
    {"label": "Age Gap", "color": pastelLavender},
    {"label": "Forbidden", "color": pastelGrey},
    {"label": "Menage", "color": pastelPink},
    {"label": "Roommates", "color": pastelPeach},
  ];

  const TagSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Container(
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tag['color'],
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                tag['label'],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textBrown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
