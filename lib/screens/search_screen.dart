// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  bool _isSearching = false;
  String? _error;
  List<String> _suggestions = [];
  Timer? _debounceTimer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Show suggestions dropdown if typing
    setState(() {
      _showSuggestions = _searchController.text.isNotEmpty;
    });

    // Set new debounce timer - search after 300ms of no typing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSuggestions(_searchController.text);
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final uri = Uri.parse(
          "http://10.186.144.146:8080/api/search?query=${query.toLowerCase().trim()}");
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = List<String>.from(data['suggestions'] ?? []);
          _isSearching = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _searchPokemon(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _pokemonData = null;
      _showSuggestions = false;
    });

    try {
      final uri = Uri.parse(
          "http://10.186.144.146:8080/api?query=${query.toLowerCase().trim()}");

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Validate required fields
        if (decodedData['name'] == null) {
          setState(() {
            _error = 'Invalid Pokémon data received';
          });
          return;
        }

        setState(() {
          _pokemonData = decodedData;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'Pokémon not found! Try another name.';
        });
      } else {
        setState(() {
          _error = 'Server error (${response.statusCode}). Please try again.';
        });
      }
    } catch (e) {
      print("Search error: $e");
      setState(() {
        _error = 'Network error: ${e.toString()}';
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
            // Search Bar with Suggestions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name... (type to see suggestions)',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.blueGrey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.amberAccent),
                      suffixIcon: _isSearching
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.amberAccent),
                                ),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) => _onSearchChanged(),
                    onSubmitted: (value) {
                      _searchPokemon(value);
                    },
                  ),
                  // Suggestions Dropdown
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amberAccent.withOpacity(0.3),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.catching_pokemon,
                                color: Colors.amberAccent, size: 20),
                            title: Text(
                              suggestion.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward,
                                color: Colors.amberAccent.withOpacity(0.5),
                                size: 16),
                            onTap: () {
                              _searchController.text = suggestion;
                              _searchPokemon(suggestion);
                            },
                            hoverColor: Colors.amberAccent.withOpacity(0.1),
                          );
                        },
                      ),
                    ),
                  if (_showSuggestions && _suggestions.isEmpty && !_isSearching)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Text(
                          'No Pokémon found matching "${_searchController.text}"',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
                        // Image with fallback
                        (_pokemonData!['image'] != null &&
                                _pokemonData!['image'].toString().isNotEmpty)
                            ? Image.network(
                                _pokemonData!['image'],
                                height: 120,
                                width: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.amberAccent,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.catching_pokemon,
                                  color: Colors.amberAccent,
                                  size: 50,
                                ),
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
