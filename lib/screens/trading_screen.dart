import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TradingPage extends StatefulWidget {
  final String currentUsername;
  final List<Map<String, dynamic>> myCapturedPokemons;

  const TradingPage({
    required this.currentUsername,
    required this.myCapturedPokemons,
  });

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  static const String backendUrl =
      'https://c67a-2409-40f3-2049-b65f-a512-cdfd-d2dd-6f03.ngrok-free.app/trade'; // <-- Replace this

  String searchUsername = '';
  Map<String, dynamic>? selectedUser;
  int? selectedPokemonId;

  Future<void> fetchUser(String username) async {
    final response = await http.get(Uri.parse(
        'https://c67a-2409-40f3-2049-b65f-a512-cdfd-d2dd-6f03.ngrok-free.app/users/by-username/$username'));

    if (response.statusCode == 200) {
      setState(() {
        selectedUser = jsonDecode(response.body);
      });
    } else {
      setState(() {
        selectedUser = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    }
  }

  void selectPokemon(int pokemonId) {
    setState(() {
      selectedPokemonId = (selectedPokemonId == pokemonId) ? null : pokemonId;
    });
  }

  Future<void> performTrade() async {
    if (selectedUser == null || selectedPokemonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select a user and Pokémon before trading")),
      );
      return;
    }

    final selectedPokemon = widget.myCapturedPokemons.firstWhere(
      (p) => p['id'] == selectedPokemonId,
      orElse: () => {},
    );

    if (selectedPokemon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pokémon not found in your list")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(backendUrl), // direct POST to /trade
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_username': widget.currentUsername,
        'receiver_username': selectedUser!['username'],
        'name': selectedPokemon['name'],
        'imageUrl': selectedPokemon['imageUrl'],
        'description': selectedPokemon['description'],
        'types': selectedPokemon['types'],
        'abilities': selectedPokemon['abilities'],
        'stats': selectedPokemon['stats'],
      }),
    );

    if (response.statusCode == 201) {
      final message = jsonDecode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Trade successful: $message')),
      );
      setState(() {
        selectedUser = null;
        selectedPokemonId = null;
      });
    } else {
      final error = jsonDecode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Trade failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            Text('Trading Center', style: TextStyle(color: Colors.amberAccent)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Username search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => searchUsername = val,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.blueGrey[800],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.amberAccent),
                  onPressed: () => fetchUser(searchUsername),
                ),
              ],
            ),
            SizedBox(height: 20),

            if (selectedUser != null)
              Card(
                color: Colors.blueGrey[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(selectedUser!['photoUrl'] ?? ''),
                  ),
                  title: Text(
                    selectedUser!['name'] ?? 'Unknown',
                    style: TextStyle(
                        color: Colors.amberAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Username: ${selectedUser!['username']}",
                      style: TextStyle(color: Colors.white70)),
                ),
              ),

            SizedBox(height: 20),
            Text('Select one Pokémon to trade',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: widget.myCapturedPokemons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  final pokemon = widget.myCapturedPokemons[index];
                  final id = pokemon['id'];
                  final isSelected = selectedPokemonId == id;

                  return GestureDetector(
                    onTap: () => selectPokemon(id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.amber[800]
                            : Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(pokemon['imageUrl'], height: 100),
                          SizedBox(height: 10),
                          Text(pokemon['name'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton.icon(
              onPressed: (selectedUser != null && selectedPokemonId != null)
                  ? performTrade
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              icon: Icon(Icons.send),
              label: Text("Send Pokémon"),
            ),
          ],
        ),
      ),
    );
  }
}
