import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../driver/presentation/driver_home_screen.dart';
import '../../../../core/constants/app_colors.dart';
import 'widgets/profile_tab.dart';
import 'widgets/rider_map_view.dart';
import 'widgets/trips_tab.dart';

/// The main dashboard for the Nduthi app.
/// Handles map display, location tracking, and ride request UI for Riders.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (_currentIndex == 1) {
      return const TripsTab();
    }
    if (_currentIndex == 2) {
      return const ProfileTab();
    }
    final role = ref.watch(userRoleProvider);
    if (role == 'driver') {
      return const DriverHomeScreen();
    }

    return const RiderMapView();
  }
}
