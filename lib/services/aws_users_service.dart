import 'dart:convert';  // Import na početku fajla
import 'package:http/http.dart' as http;

class AWSUsersService {
  // API URL ka tvojoj Lambda funkciji koja pristupa DynamoDB
  final String apiUrl = 'https://poiw4thrb5.execute-api.eu-north-1.amazonaws.com/prod/saveUser'; // Zameni sa stvarnim URL-om

  // Funkcija za slanje podataka korisnika prema API Gateway-u
  Future<void> saveUserData(String userId, String email, String displayName, String photoURL) async {
    // Kreiranje payload-a koji ćemo poslati u telo zahteva
    final Map<String, dynamic> requestPayload = {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'created_at': DateTime.now().toString(),
    };

    try {
      // Slanje POST zahteva prema API Gateway-u
      final response = await http.post(
        Uri.parse(apiUrl),  // URL API-ja
        headers: {'Content-Type': 'application/json'},  // Header za JSON format
        body: json.encode(requestPayload),  // Serijalizacija podataka u JSON
      );

      // Provera da li je zahtev bio uspešan
      if (response.statusCode == 200) {
        print('User data saved successfully!');
      } else {
        print('Failed to save user data: ${response.body}');
      }
    } catch (e) {
      // Obrada grešaka ako dođe do problema sa API pozivom
      print('Error saving user data: $e');
    }
  }
}
