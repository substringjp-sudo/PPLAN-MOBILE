
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    Text('Map Screen'),
    Text('Likes Screen'),
    Text('Profile Screen'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(LucideIcons.home,
                  color: _selectedIndex == 0
                      ? AppColors.primary
                      : AppColors.mutedText),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(LucideIcons.map,
                  color: _selectedIndex == 1
                      ? AppColors.primary
                      : AppColors.mutedText),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40), // The space for the FAB
            IconButton(
              icon: Icon(LucideIcons.heart,
                  color: _selectedIndex == 2
                      ? AppColors.primary
                      : AppColors.mutedText),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(LucideIcons.user,
                  color: _selectedIndex == 3
                      ? AppColors.primary
                      : AppColors.mutedText),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(LucideIcons.pencil, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
