import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static Future<List<Map<String, dynamic>>> fetchCapturedPokemons(
      String username) async {
    final url = Uri.parse(
      "http://4c95-2409-40f3-2049-b65f-7df6-e8d3-7741-2d5f.ngrok-free.app/captured/$username",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception(
          "Failed to load captured Pokémon (Status: ${response.statusCode})");
    }
  }
}
