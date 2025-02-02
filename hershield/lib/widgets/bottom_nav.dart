import 'package:flutter/material.dart';
import 'package:hershield/screens/chat_screen.dart';
import 'package:hershield/screens/userprofile_screen.dart';
import '../home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/community_feed.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1; // Default to Panic Screen
  final List<Widget> _screens = [
    const UserProfileScreen(), // User profile screen
    const HomeScreen(),   // Panic screen (home)
    const MapScreen(),   // Area profiling screen
    const CommunityFeed(),// Community feed screen (blank for now)
    const ChatScreen() ,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Your Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Panic Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Area Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_moderator_sharp),
            label: 'Arya AI',
          ),
        ],
      ),
    );
  }
}