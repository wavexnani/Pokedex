// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print

import 'package:flutter/material.dart';
import 'dart:math';

class PremiumCardCarousel extends StatefulWidget {
  const PremiumCardCarousel({super.key});

  @override
  _PremiumCardCarouselState createState() => _PremiumCardCarouselState();
}

class _PremiumCardCarouselState extends State<PremiumCardCarousel> {
  PageController _pageController = PageController(viewportFraction: 0.7);
  double currentPage = 0.0;

  List<String> pokemonNames = ['Charizard', 'Pikachu', 'Bulbasaur', 'Mewtwo'];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      try {
        setState(() {
          currentPage = _pageController.page ?? 0.0;
        });
      } catch (e) {
        print("Error in PageController listener: $e");
      }
    });
  }

  @override
  void dispose() {
    try {
      _pageController.dispose();
    } catch (e) {
      print("Error disposing PageController: $e");
    }
    super.dispose();
  }

  Widget buildCard(int index) {
    double scale = max(0.85, 1 - (currentPage - index).abs() * 0.15);
    double elevation = (currentPage - index).abs() < 0.3 ? 15 : 5;

    return Transform.scale(
      scale: scale,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(30),
        color: Colors.black87, // Dark background for the card
        child: SizedBox(
          width: 180,
          height: 350,
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Colors.amberAccent, width: 3), // Amber border
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.catching_pokemon,
                  size: 70,
                  color: Colors.amberAccent, // Amber icon color
                ),
                SizedBox(height: 20),
                Text(
                  pokemonNames[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: pokemonNames.length,
        itemBuilder: (context, index) {
          return buildCard(index);
        },
      ),
    );
  }
}
