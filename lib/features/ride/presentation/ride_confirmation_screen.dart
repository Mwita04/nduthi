import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/ride_model.dart';
import 'ride_provider.dart';

class RideConfirmationScreen extends ConsumerWidget {
  final String pickup;
  final String destination;

  const RideConfirmationScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Ride'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.two_wheeler, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            _buildInfoCard('Pickup Location', pickup, Icons.my_location, Colors.green),
            const SizedBox(height: 16),
            _buildInfoCard('Destination', destination, Icons.flag, Colors.orange),
            const Spacer(),
            const Text(
              'Estimated Fare: KES 250',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Create the ride request object
                final ride = RideModel(
                  id: '', // Will be set by Firestore
                  passengerId: user.uid,
                  pickupAddress: pickup,
                  destinationAddress: destination,
                  // Placeholder locations for now (Nairobi center)
                  pickupLocation: const GeoPoint(-1.286389, 36.817223),
                  destinationLocation: const GeoPoint(-1.2921, 36.8219),
                  fare: 250.0,
                  createdAt: DateTime.now(),
                );

                try {
                  final rideId = await ref.read(rideRepositoryProvider).requestRide(ride);
                  ref.read(activeRideIdProvider.notifier).state = rideId;
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Finding a rider near you...')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('CONFIRM RIDE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
