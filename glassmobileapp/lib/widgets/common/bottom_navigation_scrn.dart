import 'package:flutter/material.dart';
import 'bottom_navigation_bar_widget.dart';

// Example of how to use the independent bottom navigation bar
class ExampleScreenWithBottomNav extends StatefulWidget {
  const ExampleScreenWithBottomNav({super.key});

  @override
  State<ExampleScreenWithBottomNav> createState() => _ExampleScreenWithBottomNavState();
}

class _ExampleScreenWithBottomNavState extends State<ExampleScreenWithBottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: const Center(
        child: Text('This screen has the independent bottom navigation bar'),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Custom navigation logic here
        },
      ),
    );
  }
}

// Alternative usage with the helper class
class AnotherExampleScreen extends StatefulWidget {
  const AnotherExampleScreen({super.key});

  @override
  State<AnotherExampleScreen> createState() => _AnotherExampleScreenState();
}

class _AnotherExampleScreenState extends State<AnotherExampleScreen> {
  int _currentIndex = 2; // Cart tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Example'),
      ),
      body: const Center(
        child: Text('Using the helper class method'),
      ),
      bottomNavigationBar: BottomNavHelper.build(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Custom logic here
        },
      ),
    );
  }
}
