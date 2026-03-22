import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String apiUrl =
      'https://0qn19oc3e2.execute-api.eu-north-1.amazonaws.com/prod/getBooks';

  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Proveri da li je lista i da nije prazna
        if (data is List && data.isNotEmpty) {
          return data
              .map((json) => Book.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          print('No book data found.');
          return [];
        }
      } else {
        throw Exception('Failed to load books (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }
}
