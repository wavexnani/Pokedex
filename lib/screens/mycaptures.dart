import 'package:flutter/material.dart';
import 'package:project_x/utils/usercapfun.dart';

class MyCapturesPage extends StatefulWidget {
  final String username;

  const MyCapturesPage({Key? key, required this.username}) : super(key: key);

  @override
  _MyCapturesPageState createState() => _MyCapturesPageState();
}

class _MyCapturesPageState extends State<MyCapturesPage> {
  List<Map<String, dynamic>> capturedPokemons = [];
  bool isLoading = true;

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
      print("Error: $e");
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Captured Pokémon',
          style: TextStyle(color: Colors.amberAccent),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent))
          : capturedPokemons.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't captured any Pokémon yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: capturedPokemons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final pokemon = capturedPokemons[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[900],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 8),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                pokemon['description'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
