// ignore_for_file: deprecated_member_use, avoid_print, use_key_in_widget_constructors
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_x/screens/indipoke_screen.dart';
import 'package:project_x/screens/search_screen.dart';
import 'package:project_x/utils/scrollable.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> futurePokemonList;
  @override
  void initState() {
    super.initState();
    futurePokemonList = fetchPokemonDetails();
  }

  Future<List<Map<String, dynamic>>> fetchPokemonDetails() async {
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=20&offset=0';
    final response = await http.get(Uri.parse(url));
    final pokemons = <Map<String, dynamic>>[];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];

      for (var result in results) {
        final detailsResponse = await http.get(Uri.parse(result['url']));
        if (detailsResponse.statusCode == 200) {
          final details = jsonDecode(detailsResponse.body);
          final id = details['id'];
          final name = details['forms'][0]['name'];
          final imageUrl =
              details['sprites']['other']['official-artwork']['front_shiny'];

          // Extract stats
          final stats = <String, int>{};
          for (var stat in details['stats']) {
            final statName = stat['stat']['name'];
            final baseStat = stat['base_stat'];
            stats[statName] = baseStat;
          }

          // Extract types
          final types = (details['types'] as List)
              .map((typeInfo) => typeInfo['type']['name'] as String)
              .toList();

          // Extract abilities
          final abilities = (details['abilities'] as List)
              .map((abilityInfo) => abilityInfo['ability']['name'] as String)
              .toList();

          // Fetch description from species endpoint
          final speciesUrl = details['species']['url'];
          final speciesResponse = await http.get(Uri.parse(speciesUrl));
          String description = 'No description available.';
          if (speciesResponse.statusCode == 200) {
            final speciesData = jsonDecode(speciesResponse.body);
            final flavorTextEntries =
                speciesData['flavor_text_entries'] as List;
            final englishEntry = flavorTextEntries.firstWhere(
              (entry) => entry['language']['name'] == 'en',
              orElse: () => null,
            );
            if (englishEntry != null) {
              description = (englishEntry['flavor_text'] as String)
                  .replaceAll('\n', ' ')
                  .replaceAll('\f', ' ');
            }
          }

          pokemons.add({
            'id': id,
            'name': name,
            'imageUrl': imageUrl,
            'description': description,
            'stats': stats,
            'types': types,
            'abilities': abilities,
          });
        }
      }
    }

    return pokemons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amberAccent,
        backgroundColor: Colors.blueGrey[900],
        items: [
          BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () => {},
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.catching_pokemon,
                color: Colors.white,
              ),
              label: 'My Captures'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.currency_exchange,
                color: Colors.white,
              ),
              label: 'Setting'),
        ],
      ), // Dark background for a futuristic look
      appBar: AppBar(
        title: Text(
          'Pokédex',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent, // Amber for a futuristic pop
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.amberAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section with a dark background and neon accent
            Container(
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.blueGrey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Pokédex!',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Explore your favorite Pokémon and discover their details.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Button action here
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.amberAccent),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        )),
                      ),
                      child: Text(
                        'Start Exploring',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium Pokémon Carousel
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 66.0),
              child: PremiumCardCarousel(),
            ),

            // New Section with animated grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Pokémon',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                        SizedBox(height: 10),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: futurePokemonList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 50.0),
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.amberAccent)),
                              ));
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            } else {
                              final pokemons = snapshot.data!;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: pokemons.length,
                                itemBuilder: (context, index) {
                                  final pokemon = pokemons[index];
                                  return GestureDetector(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PokemonDetailPage(
                                            name: pokemon['name'],
                                            imageUrl: pokemon['imageUrl'],
                                            description: pokemon['description'],
                                            stats: Map<String, int>.from(
                                                pokemon['stats']),
                                            types: List<String>.from(
                                                pokemon['types']),
                                            abilities: List<String>.from(
                                                pokemon['abilities']),
                                          ),
                                        ),
                                      )
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[900],
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              pokemon['imageUrl'],
                                              height: 200,
                                              width: 200,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              pokemon['name'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
