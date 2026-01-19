import 'package:flutter/material.dart';
import 'volunteer_home_screen.dart';
import 'volunteer_requests_screen.dart';
import '../profile/profile_screen.dart';

class VolunteerBottomNav extends StatefulWidget {
  const VolunteerBottomNav({super.key});

  @override
  State<VolunteerBottomNav> createState() => _VolunteerBottomNavState();
}

class _VolunteerBottomNavState extends State<VolunteerBottomNav> {
  int _index = 0;

  final _pages = const [
    VolunteerHomeScreen(),
    VolunteerRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFF0C831F),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
