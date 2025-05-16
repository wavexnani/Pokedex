import 'package:flutter/material.dart';

class PokemonDetailPage extends StatelessWidget {
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
                            imageUrl,
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
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
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Types with white background
                  _buildChipsRow("Types", types, Colors.white, Colors.blueGrey),

                  const SizedBox(height: 10),

                  // Abilities with light blue
                  _buildChipsRow("Abilities", abilities, Colors.lightBlueAccent,
                      Colors.blueGrey),

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
                        ...stats.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                // Handle capture logic here
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
          Text(
            title,
            style: TextStyle(
              color: chipColor == Colors.white ? Colors.amberAccent : chipColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
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
        ],
      ),
    );
  }
}
