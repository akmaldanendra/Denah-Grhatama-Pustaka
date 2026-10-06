import 'package:flutter/material.dart';
import '../main.dart';
import '../models/room_model.dart';
import 'map_screen.dart';
import 'room_list_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Navigasi global ke tab peta dan highlight ruangan tertentu
  static void goToMap(BuildContext context, RoomModel room) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?._goToMapWithRoom(room);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _mapKey = GlobalKey<MapScreenState>();

  void _goToMapWithRoom(RoomModel room) {
    setState(() => _currentIndex = 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapKey.currentState?.focusRoom(room);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : Colors.white;

    final tabs = [
      MapScreen(key: _mapKey),
      const RoomListScreen(),
      const InfoScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.map_outlined,
                  color: _currentIndex == 0
                      ? AppColors.primary
                      : (isDark ? Colors.white38 : Colors.black38)),
              selectedIcon: const Icon(Icons.map_rounded,
                  color: AppColors.primary),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted_outlined,
                  color: _currentIndex == 1
                      ? AppColors.primary
                      : (isDark ? Colors.white38 : Colors.black38)),
              selectedIcon: const Icon(Icons.format_list_bulleted_rounded,
                  color: AppColors.primary),
              label: 'Ruangan',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline_rounded,
                  color: _currentIndex == 2
                      ? AppColors.primary
                      : (isDark ? Colors.white38 : Colors.black38)),
              selectedIcon: const Icon(Icons.info_rounded,
                  color: AppColors.primary),
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }
}
