import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.library_music_rounded),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.featured_play_list_rounded),
          label: 'Playlists',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline_rounded),
          label: 'Info',
        ),
      ],
    );
  }
}
