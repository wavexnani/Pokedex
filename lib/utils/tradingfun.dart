import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> tradePokemon({
  required String fromUsername,
  required String toUsername,
  required String name,
  required String imageUrl,
  required String description,
  required List<String> types,
  required List<String> abilities,
  required Map<String, dynamic> stats,
}) async {
  final url = Uri.parse("https://your-server.ngrok-free.app/trade");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "from_username": fromUsername,
      "to_username": toUsername,
      "name": name,
      "imageUrl": imageUrl,
      "description": description,
      "types": types,
      "abilities": abilities,
      "stats": stats,
    }),
  );

  if (response.statusCode == 200) {
    print("Pokémon traded successfully");
  } else {
    print("Failed to trade Pokémon: ${response.body}");
  }
}
