
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://0qn19oc3e2.execute-api.eu-north-1.amazonaws.com/prod/getBooks';

  static Future<List<dynamic>> fetchBooks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }
}
