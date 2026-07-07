import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nduthi/feature/ride/presentation/ride_confirmation_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  LatLng _currentPosition = const LatLng(-1.2921, 36.8219);
  bool _isLoadingLocation = true;
  String _locationError = '';

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'Please enable location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _locationError = 'Location permission is required.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location.';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isRider = authVM.userRole == 'rider';

    return Scaffold(
      body: _buildCurrentTab(isRider, authVM),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(bool isRider, AuthViewModel authVM) {
    if (_currentIndex == 1) {
      return const Center(
        child: Text('My Trips\n(Coming soon)', textAlign: TextAlign.center),
      );
    }
    if (_currentIndex == 2) {
      return _buildProfileTab(authVM);
    }
    return isRider ? _buildRiderDashboard() : _buildPassengerHome();
  }

  Widget _buildPassengerHome() {
    return Column(
      children: [
        Expanded(
          child: _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : _locationError.isNotEmpty
              ? Center(
                  child: Text(
                    _locationError,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
        ),
        _buildPassengerBottomSheet(),
      ],
    );
  }

  Widget _buildPassengerBottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Where to?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pickupController,
            decoration: _buildInputDecoration(
              'Pickup location',
              Icons.my_location,
              Colors.green,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _destinationController,
            decoration: _buildInputDecoration(
              'Destination',
              Icons.flag,
              Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onFindRiderPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'FIND A RIDER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    Color color,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _onFindRiderPressed() {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup and destination')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideConfirmationScreen(
          pickup: _pickupController.text,
          destination: _destinationController.text,
        ),
      ),
    );
  }

  Widget _buildRiderDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.two_wheeler, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            'Rider Dashboard',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are currently OFFLINE',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            ),
            child: const Text(
              'GO ONLINE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(AuthViewModel authVM) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            authVM.userName ?? 'User',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            authVM.userRole?.toUpperCase() ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            onTap: () async {
              await authVM.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
