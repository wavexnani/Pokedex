import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> favoritePokemon({
  required int userId,
  required String name,
  required String imageUrl,
  required String description,
  required List<String> types,
  required List<String> abilities,
  required Map<String, dynamic> stats,
}) async {
  final url = Uri.parse("http://<YOUR_BACKEND_URL>/favorites");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "user_id": userId,
      "name": name,
      "image_url": imageUrl,
      "description": description,
      "types": types,
      "abilities": abilities,
      "stats": stats,
    }),
  );

  if (response.statusCode == 201) {
    print("Favorite added successfully");
  } else {
    print("Failed to add favorite: ${response.body}");
  }
}
