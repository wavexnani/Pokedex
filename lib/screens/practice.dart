import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool isSelected = false;
  final int length = 30;
  bool inSelectionMode = true;
  bool isGridMode = false;
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice',
          style: TextStyle(),
        ),
        leading: inSelectionMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    inSelectionMode = false;
                  });
                },
                icon: Icon(Icons.close))
            : const SizedBox(),
        actions: [
          if (isGridMode)
            IconButton(
              onPressed: () {
                setState(() {
                  isGridMode = false;
                });
              },
              icon: Icon(Icons.list),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  isGridMode = true;
                });
              },
              icon: Icon(Icons.grid_on),
            ),
          if (inSelectionMode)
            TextButton(
                onPressed: () {
                  
                },
                child: !selectAll
                    ? const Text('Select All')
                    : const Text("Unselect All")),
        ],
      ),
    );
  }
}
