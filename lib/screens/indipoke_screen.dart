// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project_x/utils/capfun.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokemonDetailPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String description;
  final Map<String, int> stats;
  final List<String> types;
  final List<String> abilities;

  const PokemonDetailPage({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.stats,
    required this.types,
    required this.abilities,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  String? username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Colors.blueGrey,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Image and Name
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.network(
                            widget.imageUrl,
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.name,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Description panel
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Types with white background
                  _buildChipsRow(
                      "Types", widget.types, Colors.white, Colors.blueGrey),

                  const SizedBox(height: 10),

                  // Abilities with light blue
                  _buildChipsRow("Abilities", widget.abilities,
                      Colors.lightBlueAccent, Colors.blueGrey),

                  const SizedBox(height: 20),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stats',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...widget.stats.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: entry.value / 150,
                                      backgroundColor: Colors.white10,
                                      color: Colors.amberAccent,
                                      minHeight: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(onPressed: (){}, child: Text("error"))
                ],
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                capturePokemon(
                    username: username!,
                    name: widget.name,
                    imageUrl: widget.imageUrl,
                    description: widget.description,
                    types: widget.types,
                    abilities: widget.abilities,
                    stats: widget.stats);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pokémon captured!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: const Text(
                "Capture Pokémon",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsRow(
      String title, List<String> items, Color chipColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                color:
                    chipColor == Colors.white ? Colors.amberAccent : chipColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              spacing: 10,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(
                        item,
                        style: TextStyle(color: textColor),
                      ),
                      backgroundColor: chipColor.withOpacity(0.3),
                      shape: StadiumBorder(
                        side: BorderSide(color: chipColor),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
