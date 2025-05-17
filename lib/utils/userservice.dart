// utils/usercapfun.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl =
      "http://a3a7-2409-40f3-2049-b65f-d9bf-6538-9066-d955.ngrok-free.app"; // Update this

  static Future<Map<String, dynamic>?> getUserByUsername(
      String username) async {
    final url = Uri.parse('$baseUrl/users/by-username/$username');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
