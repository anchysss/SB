class Book {
  final String bookId;
  final String bookName;
  final String coverImage;
  final String shortSummary;
  final List<String> genre;
  final String authorName;
  final double rate;

  Book({
    required this.bookId,
    required this.bookName,
    required this.coverImage,
    required this.shortSummary,
    required this.genre,
    required this.authorName,
    required this.rate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['book_id'] ?? '',
      bookName: json['book_name'] ?? '',
      coverImage: json['cover_image'] ?? '',
      shortSummary: json['short_summary'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      authorName: json['author_name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
    );
  }
}
