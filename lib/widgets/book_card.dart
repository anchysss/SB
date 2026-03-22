import 'package:flutter/material.dart';
import '../theme.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;

  const BookCard({
    super.key,
    this.title = 'Book Title',
    this.author = 'Author Name',
    this.imageUrl = 'https://via.placeholder.com/150',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 220, // ⬅️ Smanjena visina da spreči overflow
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: pastelCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/book_placeholder.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          // Title and author
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pastelTextBrown,
                    fontSize: 13.5, // ⬅️ Malo smanjen font
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2), // ⬅️ Manji razmak
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pastelTextBrown.withOpacity(0.7),
                    fontSize: 11.5, // ⬅️ Malo smanjen font
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
