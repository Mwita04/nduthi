import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ride_repository.dart';
import '../domain/ride_model.dart';

final rideRepositoryProvider = Provider((ref) => RideRepository());

/// Stream of pending rides for drivers.
final pendingRidesProvider = StreamProvider<List<RideModel>>((ref) {
  return ref.watch(rideRepositoryProvider).getPendingRides();
});

/// State for the current ride being tracked by a passenger.
final activeRideIdProvider = StateProvider<String?>((ref) => null);

/// Stream of the currently active ride's details.
final activeRideProvider = StreamProvider<RideModel?>((ref) {
  final rideId = ref.watch(activeRideIdProvider);
  if (rideId == null) return Stream.value(null);
  return ref.watch(rideRepositoryProvider).watchRide(rideId);
});
