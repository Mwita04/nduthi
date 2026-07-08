import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ride/presentation/ride_provider.dart';
import '../../ride/domain/ride_model.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRidesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),
      body: pendingAsync.when(
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(child: Text('No pending rides at the moment'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final RideModel ride = rides[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ride.pickupAddress} → ${ride.destinationAddress}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Fare: KES ${ride.fare.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                try {
                                  await ref
                                      .read(rideRepositoryProvider)
                                      .acceptRide(ride.id, user.uid);
                                  ref
                                      .read(activeRideIdProvider.notifier)
                                      .setId(ride.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Ride accepted')));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to accept ride: $e')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('ACCEPT',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('DETAILS'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading rides: $e')),
      ),
    );
  }
}
