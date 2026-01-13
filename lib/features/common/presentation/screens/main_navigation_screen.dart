
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/likes/presentation/screens/likes_screen.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile/features/trips/presentation/screens/my_trips_screen.dart';

// This provider will hold the currently selected tab index
final selectedPageIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  // List of pages to be displayed in the navigation
  final List<Widget> _pages = const [
    HomeScreen(),
    MyTripsScreen(),
    LikesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageIndex = ref.watch(selectedPageIndexProvider);

    return Scaffold(
      extendBody: true, // Allows the body to go behind the bottom app bar
      body: IndexedStack(
        index: selectedPageIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.surface,
        child: SizedBox(
          height: 60, // Standard height for BottomAppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left side icons
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildNavIcon(context, ref, icon: LucideIcons.home, index: 0),
                  _buildNavIcon(context, ref, icon: LucideIcons.map, index: 1),
                ],
              ),
              // Right side icons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _buildNavIcon(context, ref, icon: LucideIcons.heart, index: 2),
                  _buildNavIcon(context, ref, icon: LucideIcons.user, index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(LucideIcons.pencil, color: Colors.white, size: 28),
    );
  }

  Widget _buildNavIcon(BuildContext context, WidgetRef ref, {required IconData icon, required int index}) {
    final selectedPageIndex = ref.watch(selectedPageIndexProvider);
    final isSelected = selectedPageIndex == index;

    return IconButton(
      icon: Icon(icon, color: isSelected ? AppColors.primary : AppColors.mutedText),
      onPressed: () => ref.read(selectedPageIndexProvider.notifier).state = index,
      tooltip: '${icon.toString()}',
    );
  }
}
