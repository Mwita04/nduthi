import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../ride/presentation/ride_confirmation_screen.dart';
import '../../ride/presentation/ride_provider.dart';
import '../../ride/domain/ride_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The main dashboard for the Nduthi app.
/// Handles map display, location tracking, and ride request UI for Riders.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  LatLng _currentPosition = const LatLng(-1.2921, 36.8219);
  bool _isLoadingLocation = true;
  String _locationError = '';
  GoogleMapController? _mapController;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Requests location permission and gets the user's current coordinates.
  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationError = 'Please enable location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationError = 'Location permission is required.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        
        // Move camera to current position if map is ready
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Failed to get location.';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We are focusing exclusively on the Rider side for now.
    return Scaffold(
      body: _buildCurrentTab(),
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

  Widget _buildCurrentTab() {
    if (_currentIndex == 1) return const Center(child: Text('My Trips\n(Coming soon)', textAlign: TextAlign.center));
    if (_currentIndex == 2) return _buildProfileTab();
    return _buildPassengerHome();
  }

  // ==================== RIDER HOME ====================
  Widget _buildPassengerHome() {
    final activeRide = ref.watch(activeRideProvider).value;

    return Stack(
      children: [
        // Full screen Map
        _isLoadingLocation
            ? const Center(child: CircularProgressIndicator())
            : _locationError.isNotEmpty
                ? Center(child: Text(_locationError, style: const TextStyle(color: Colors.red)))
                : GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    markers: _createMarkers(activeRide),
                  ),
        
        // Overlay UI
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: activeRide != null
              ? _buildActiveRideCard(activeRide)
              : _buildPassengerBottomSheet(),
        ),
      ],
    );
  }

  /// Generates markers for the map based on the active ride.
  Set<Marker> _createMarkers(RideModel? ride) {
    Set<Marker> markers = {};
    if (ride != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(ride.pickupLocation.latitude, ride.pickupLocation.longitude),
          infoWindow: InfoWindow(title: 'Pickup: ${ride.pickupAddress}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(ride.destinationLocation.latitude, ride.destinationLocation.longitude),
          infoWindow: InfoWindow(title: 'Destination: ${ride.destinationAddress}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
    return markers;
  }

  /// UI Card shown when a ride is active (requested or accepted).
  Widget _buildActiveRideCard(RideModel ride) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.two_wheeler, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.status == RideStatus.pending ? 'Finding a Nduthi...' : 'Ride Accepted!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ride.status == RideStatus.pending ? 'Wait for a driver to accept' : 'Driver is on the way',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (ride.status == RideStatus.pending)
                const CircularProgressIndicator(strokeWidth: 2)
            ],
          ),
          const SizedBox(height: 20),
          _buildRideDetailsMini(ride),
          const SizedBox(height: 24),
          if (ride.status == RideStatus.pending)
            OutlinedButton(
              onPressed: () {
                // For now, just clear the local state.
                // In a full implementation, this would update the Firestore document status to 'cancelled'.
                ref.read(activeRideIdProvider.notifier).state = null;
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CANCEL REQUEST'),
            ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsMini(RideModel ride) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.my_location, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(ride.pickupAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.flag, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(ride.destinationAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }

  /// The standard "Where to?" sheet for Riders.
  Widget _buildPassengerBottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Where to?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _pickupController,
            decoration: _buildInputDecoration('Pickup location', Icons.my_location, Colors.green),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _destinationController,
            decoration: _buildInputDecoration('Destination', Icons.flag, Colors.orange),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onFindRiderPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('FIND A NDUTHI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  void _onFindRiderPressed() {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter pickup and destination')));
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

  // ==================== PROFILE ====================
  Widget _buildProfileTab() {
    final userRole = ref.read(userRoleProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(user?.email ?? 'User', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(userRole?.toUpperCase() ?? 'NONE', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 18)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
