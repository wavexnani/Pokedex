import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCapturesPage extends StatefulWidget {
  final String username;

  const MyCapturesPage({Key? key, required this.username}) : super(key: key);

  @override
  _MyCapturesPageState createState() => _MyCapturesPageState();
}

class _MyCapturesPageState extends State<MyCapturesPage> {
  List<dynamic> capturedPokemons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCapturedPokemons();
  }

  Future<void> fetchCapturedPokemons() async {
    final url = Uri.parse(
        "https://c67a-2409-40f3-2049-b65f-a512-cdfd-d2dd-6f03.ngrok-free.app/captured/${widget.username}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          capturedPokemons = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            "Failed to load captured Pokémon. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching captured Pokémon: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'My Captured Pokémons',
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : capturedPokemons.isEmpty
              ? const Center(
                  child: Text(
                  "You haven't captured any Pokémon yet.",
                  style: TextStyle(color: Colors.amber),
                ))
              : ListView.builder(
                  itemCount: capturedPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = capturedPokemons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Image.network(
                          pokemon['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(pokemon['name']),
                        subtitle: Text(pokemon['description']),
                      ),
                    );
                  },
                ),
    );
  }
}
