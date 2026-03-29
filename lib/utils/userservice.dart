// utils/usercapfun.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = "http://10.186.144.146:8080";

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
