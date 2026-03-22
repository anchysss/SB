import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> postComment({
  required String lambdaUrl,
  required String bookId,
  required int chapterNumber,
  required String userId,
  required String username,
  required String text,
}) async {
  final commentId = DateTime.now().millisecondsSinceEpoch.toString();
  final timestamp = DateTime.now().toUtc().toIso8601String();

  final body = {
    "book_id": bookId,
    "chapter_number": chapterNumber,
    "comment_id": commentId,
    "user_id": userId,
    "username": username,
    "text": text,
    "timestamp": timestamp,
  };

  try {
    final response = await http.post(
      Uri.parse(lambdaUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("✅ Komentar uspešno dodat.");
      return true;
    } else {
      print("❌ Greška pri dodavanju komentara: ${response.body}");
      return false;
    }
  } catch (e) {
    print("❗ Greška pri slanju komentara: $e");
    return false;
  }
}
