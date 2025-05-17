import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GuessPokemonPage extends StatefulWidget {
  const GuessPokemonPage({super.key});

  @override
  State<GuessPokemonPage> createState() => _GuessPokemonPageState();
}

class _GuessPokemonPageState extends State<GuessPokemonPage> {
  bool isRevealed = false;
  String guess = "";
  int points = 0;

  String? pokemonName;
  String? pokemonImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRandomPokemon();
  }

  Future<void> fetchRandomPokemon() async {
    setState(() {
      isLoading = true;
      isRevealed = false;
      guess = "";
    });

    final randomId = Random().nextInt(300) + 1; // Limit to first 300 Pokémon
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pokemonName = data['name'];
        pokemonImageUrl =
            data['sprites']['other']['official-artwork']['front_default'];
        isLoading = false;
      });
    } else {
      setState(() {
        pokemonName = 'missingno';
        pokemonImageUrl = null;
        isLoading = false;
      });
    }
  }

  void checkGuess() {
    if (guess.trim().toLowerCase() == pokemonName?.toLowerCase()) {
      setState(() {
        isRevealed = true;
        points += 10;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong guess! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Points: $points",
            style: const TextStyle(color: Colors.amberAccent)),
        iconTheme: const IconThemeData(color: Colors.amberAccent),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent))
          : pokemonImageUrl == null
              ? const Center(child: Text("Failed to load Pokémon."))
              : Stack(
                  children: [
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
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Column(
                          children: [
                            const SizedBox(height: 80),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
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
                              child: isRevealed
                                  ? Column(
                                      children: [
                                        Image.network(pokemonImageUrl!,
                                            height: 280, fit: BoxFit.contain),
                                        const SizedBox(height: 12),
                                        Text(
                                          pokemonName!.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                          Colors.black, BlendMode.srcATop),
                                      child: Image.network(
                                        pokemonImageUrl!,
                                        height: 280,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: TextField(
                                onChanged: (value) => guess = value,
                                enabled: !isRevealed,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Guess the Pokémon name",
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!isRevealed)
                              ElevatedButton(
                                onPressed: checkGuess,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text("Submit Guess"),
                              ),
                            if (isRevealed)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: fetchRandomPokemon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightGreenAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text("Next Pokémon"),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
