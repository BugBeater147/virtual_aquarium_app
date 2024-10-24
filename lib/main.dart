import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(VirtualAquariumApp());
}

class VirtualAquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with TickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.orange; // Default color to orange
  double selectedSpeed = 1.0;

  @override
  void dispose() {
    // Dispose all animation controllers when the screen is closed
    for (var fish in fishList) {
      fish.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Column(
        children: [
          // Aquarium container
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              border: Border.all(),
            ),
            child: Stack(
              children: fishList.map((fish) => fish.buildFish()).toList(),
            ),
          ),
          // Speed Slider
          Slider(
            value: selectedSpeed,
            min: 0.5,
            max: 3.0,
            onChanged: (value) {
              setState(() {
                selectedSpeed = value;
                for (var fish in fishList) {
                  fish.updateSpeed(value); // Update speed for all fish
                }
              });
            },
            label: "Speed: ${selectedSpeed.toStringAsFixed(1)}",
          ),
          // Color Picker
          DropdownButton<Color>(
            value: selectedColor,
            items: [
              DropdownMenuItem(
                child: Text('Red'),
                value: Colors.red,
              ),
              DropdownMenuItem(
                child: Text('Orange'),
                value: Colors.orange,
              ),
              DropdownMenuItem(
                child: Text('Green'),
                value: Colors.green,
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedColor = value!;
              });
            },
          ),
          // Add Fish Button
          ElevatedButton(
            onPressed: _addFish,
            child: Text('Add Fish'),
          ),
          // Save Settings Button
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed, vsync: this));
      });
    }
  }

  void _saveSettings() {
    // Save settings using SQLite (to be implemented)
  }
}

class Fish {
  final Color color;
  double speed;
  late AnimationController controller;
  late Animation<Offset> animation;

  Fish({required this.color, required this.speed, required TickerProvider vsync}) {
    controller = AnimationController(
      duration: Duration(milliseconds: (5000 / speed).round()), // Adjust speed based on slider
      vsync: vsync,
    );

    _initializeMovement(); // Call the method to initialize animation
    controller.forward();
  }

  void _initializeMovement() {
    // Start fish in the exact center (Alignment.center) and move randomly
    animation = Tween<Offset>(
      begin: Offset(0, 0), // Start at the center of the container
      end: Offset(_randomPosition(), _randomPosition()),   // Random end position
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // When animation completes, restart with new random positions
        _initializeMovement();
        controller.forward(from: 0);
      }
    });
  }

  double _randomPosition() {
    return Random().nextDouble() * 2 - 1; // Position in the range of [-1, 1]
  }

  Widget buildFish() {
    return Align(
      alignment: Alignment.center,  // Start fish at the center
      child: SlideTransition(
        position: animation,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
    controller.duration = Duration(milliseconds: (5000 / speed).round());
    controller.forward(from: 0); // Restart animation with new speed
  }

  void dispose() {
    controller.dispose();
  }
}
