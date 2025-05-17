// utils/usercapfun.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl =
      "http://4c95-2409-40f3-2049-b65f-7df6-e8d3-7741-2d5f.ngrok-free.app"; // Update this

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
