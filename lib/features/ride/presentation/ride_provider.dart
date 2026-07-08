import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/ride_repository.dart';
import '../domain/ride_model.dart';

part 'ride_provider.g.dart';

@riverpod
RideRepository rideRepository(RideRepositoryRef ref) {
  return RideRepository();
}

@riverpod
Stream<List<RideModel>> pendingRides(PendingRidesRef ref) {
  return ref.watch(rideRepositoryProvider).getPendingRides();
}

// StateProviders don't always need generation if they just hold simple state,
// but we can migrate it to a Notifier for consistency, or keep it as StateProvider.
// For now, let's keep it as a Notifier for full code gen support.
@riverpod
class ActiveRideId extends _$ActiveRideId {
  @override
  String? build() => null;

  void setId(String? id) {
    state = id;
  }
}

@riverpod
Stream<RideModel?> activeRide(ActiveRideRef ref) {
  final rideId = ref.watch(activeRideIdProvider);
  if (rideId == null) return Stream.value(null);
  return ref.watch(rideRepositoryProvider).watchRide(rideId);
}
