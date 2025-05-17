// ignore_for_file: deprecated_member_use, avoid_print, use_key_in_widget_constructors
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_x/screens/game_screen.dart';
import 'package:project_x/screens/indipoke_screen.dart';
import 'package:project_x/screens/login_screen.dart';
import 'package:project_x/screens/mycaptures.dart';
import 'package:project_x/screens/search_screen.dart';
import 'package:project_x/screens/trading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> futurePokemonList;
  String? username;
  List<Map<String, dynamic>>? loadedPokemons;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MyCapturesPage(username: username!)));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => GuessPokemonPage()));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TradingPage(username: username!)));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsername();

    final fetchedFuture = fetchPokemonDetails();
    futurePokemonList = fetchedFuture;

    fetchedFuture.then((pokemonList) {
      setState(() {
        loadedPokemons = pokemonList;
      });
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blueGrey[900],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 32),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon, size: 32),
            label: 'My Captures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports, size: 32),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange, size: 32),
            label: 'Trading',
          ),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('images/profile_man.png'),
            ),
          ),
        ),
        title: username == null
            ? Text("Loading...")
            : Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    username!,
                    style: TextStyle(
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
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
              IconButton(
                onPressed: () {
                  logout();
                },
                icon: Icon(Icons.logout, color: Colors.amberAccent),
              )
            ],
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
