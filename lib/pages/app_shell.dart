import 'package:flutter/material.dart';
import 'package:prayer_basket_2/modals/create_prayer_modal.dart';
import 'home_page.dart'; // Import your actual page files

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // The order here must match the BottomNavigationBarItem order
  final List<Widget> _pages = [
    const HomePage(),
    const Scaffold(body: Center(child: Text("Basket"))),   // Placeholder
    const Scaffold(body: Center(child: Text("Guided"))),   // Placeholder
    const Scaffold(body: Center(child: Text("Social"))),   // Placeholder
    const Scaffold(body: Center(child: Text("Settings"))), // Placeholder
  ];

  void _showCreatePrayerModal() {
   showDialog(
    context: context,
    barrierDismissible: true, // Allows tapping outside to close
    barrierColor: Colors.black54, // Dim the background
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const CreatePrayerModal(),
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all pages 'alive' in the background
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF0A0A14),
        onPressed: _showCreatePrayerModal,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      
      // Floating button location matches your Figma design (bottom right)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A0A14),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Basket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Guided',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}