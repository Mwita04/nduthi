import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../ride/presentation/ride_confirmation_screen.dart';
import '../../../ride/presentation/ride_provider.dart';
import '../../../ride/domain/ride_model.dart';
import '../location_provider.dart';

class RiderMapView extends ConsumerStatefulWidget {
  const RiderMapView({super.key});

  @override
  ConsumerState<RiderMapView> createState() => _RiderMapViewState();
}

class _RiderMapViewState extends ConsumerState<RiderMapView> {
  GoogleMapController? _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeRide = ref.watch(activeRideProvider).value;
    final locationState = ref.watch(locationProvider);

    return Stack(
      children: [
        // Full screen Map
        locationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : locationState.error.isNotEmpty
                ? Center(child: Text(locationState.error, style: const TextStyle(color: AppColors.error)))
                : GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: locationState.position, 
                      zoom: AppConstants.defaultZoom,
                    ),
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

  Widget _buildActiveRideCard(RideModel ride) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.two_wheeler, color: AppColors.primary, size: 32),
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
                      style: const TextStyle(color: AppColors.textSecondary),
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
                ref.read(activeRideIdProvider.notifier).setId(null);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
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
            const Icon(Icons.my_location, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(ride.pickupAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.flag, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Expanded(child: Text(ride.destinationAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }

  Widget _buildPassengerBottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
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
            decoration: _buildInputDecoration('Pickup location', Icons.my_location, AppColors.primary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _destinationController,
            decoration: _buildInputDecoration('Destination', Icons.flag, AppColors.secondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onFindRiderPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
      fillColor: AppColors.inputFill,
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
}
