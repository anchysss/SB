
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://0qn19oc3e2.execute-api.eu-north-1.amazonaws.com/prod/getBooks';

  static Future<List<dynamic>> fetchBooks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return jsonDecode(data); // Because the body is double-encoded
    } else {
      throw Exception('Failed to load books');
    }
  }
}
