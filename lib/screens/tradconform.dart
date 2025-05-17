import 'package:flutter/material.dart';

class TradeConfirmPage extends StatelessWidget {
  final String fromUsername;
  final String toUsername;
  final Map<String, dynamic> selectedPokemon;

  const TradeConfirmPage({
    super.key,
    required this.fromUsername,
    required this.toUsername,
    required this.selectedPokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Confirm Trade",
          style: TextStyle(
            color: Colors.amberAccent,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Card(
          color: Colors.blueGrey[900],
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.amberAccent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You (${fromUsername}) are trading:",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Image.network(selectedPokemon['imageUrl'], height: 400),
                const SizedBox(height: 10),
                Text(
                  selectedPokemon['name'],
                  style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  "To: $toUsername",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Send trade request to backend
                  },
                  icon: const Icon(Icons.send),
                  label: const Text("Send Trade Request"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
