// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_x/screens/indipoke_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  String? _error;

  Future<void> _searchPokemon(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _pokemonData = null;
    });

    try {
      print("came before uri");
      final uri = Uri.parse(
          "https://95da-2409-40f3-2049-b65f-e44e-be29-4de7-4180.ngrok-free.app/api?query=${query.toLowerCase()}");

      final response = await http.get(uri);
      print("came after uri");

      if (response.statusCode == 200) {
        setState(() {
          _pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Pokémon not found!';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching Pokémon data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Search Pokémon',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.amberAccent),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.blueGrey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.amberAccent),
                ),
                onSubmitted: (value) {
                  _searchPokemon(value);
                },
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 350.0),
                child: CircularProgressIndicator(color: Colors.amberAccent),
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_error!, style: TextStyle(color: Colors.redAccent)),
              ),

            if (_pokemonData != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0),
                child: GestureDetector(
                  // Within the `FirstRoute` widget:
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailPage(
                          name: _pokemonData!['name'],
                          imageUrl: _pokemonData!['image'],
                          description: _pokemonData!['description'],
                          stats: {
                            'HP': _pokemonData!['stats']['hp'],
                            'Attack': _pokemonData!['stats']['attack'],
                            'Defense': _pokemonData!['stats']['defense'],
                            'Speed': _pokemonData!['stats']['speed'],
                            'Sp. Atk': _pokemonData!['stats']['special-attack'],
                          },
                          types: List<String>.from(_pokemonData!['types']),
                          abilities:
                              List<String>.from(_pokemonData!['abilities']),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          _pokemonData!['image'],
                          height: 120,
                        ),
                        SizedBox(width: 30),
                        Text(
                          _pokemonData!['name'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
