import 'package:flutter/material.dart';
import 'package:project_x/screens/tradconform.dart';
import 'package:project_x/utils/usercapfun.dart';
import 'package:project_x/utils/userservice.dart'; // Assuming UserService is here

class TradingPage extends StatefulWidget {
  final String username;

  const TradingPage({super.key, required this.username});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  List<Map<String, dynamic>> capturedPokemons = [];
  int? selectedPokemonId;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCapturedPokemons();
  }

  Future<void> _loadCapturedPokemons() async {
    try {
      final data = await PokemonService.fetchCapturedPokemons(widget.username);
      setState(() {
        capturedPokemons = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching captured Pokémon: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSelection(int id) {
    setState(() {
      selectedPokemonId = (selectedPokemonId == id) ? null : id;
      if (selectedPokemonId == null) {
        _searchController.clear();
      }
    });
  }

  Future<void> _handleSearch(String searchUsername) async {
    final user = await UserService.getUserByUsername(
        searchUsername.trim().toLowerCase());

    if (user != null) {
      // Navigate to trade confirmation page
      final selectedPokemon =
          capturedPokemons.firstWhere((p) => p['id'] == selectedPokemonId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TradeConfirmPage(
            toUsername: user['username'],
            fromUsername: widget.username,
            selectedPokemon: selectedPokemon,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not found"),
          backgroundColor: Colors.redAccent,
        ),
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
        title: const Text(
          'Select a Pokémon to Trade',
          style: TextStyle(color: Colors.amberAccent),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            )
          : capturedPokemons.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't captured any Pokémon!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    if (selectedPokemonId != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amberAccent),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter username to trade with',
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.amberAccent),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            ),
                            onSubmitted: _handleSearch,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          itemCount: capturedPokemons.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.78,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final pokemon = capturedPokemons[index];
                            final id = pokemon['id'];
                            final isSelected = selectedPokemonId == id;

                            return GestureDetector(
                              onTap: () => toggleSelection(id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color.fromARGB(255, 97, 175, 179)
                                          .withOpacity(0.85)
                                      : Colors.blueGrey[900],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.amberAccent
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        pokemon['imageUrl'],
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      pokemon['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        pokemon['description'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
