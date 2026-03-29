// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> capturePokemon({
  required String username,
  required String name,
  required String imageUrl,
  required String description,
  required List<String> types,
  required List<String> abilities,
  required Map<String, dynamic> stats,
}) async {
  final url = Uri.parse("http://10.186.144.146:8080/captured/add");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "username": username,
      "name": name,
      "imageUrl": imageUrl,
      "description": description,
      "types": types.join(','),
      "abilities": abilities.join(','),
      "stats": json.encode(stats),
    }),
  );

  if (response.statusCode == 201) {
    print("Pokémon captured successfully");
  } else {
    print("Failed to capture Pokémon: ${response.body}");
  }
}
