// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rideRepositoryHash() => r'356ef815b65c0a1b3e782805e02a69715b2eed81';

/// See also [rideRepository].
@ProviderFor(rideRepository)
final rideRepositoryProvider = AutoDisposeProvider<RideRepository>.internal(
  rideRepository,
  name: r'rideRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rideRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RideRepositoryRef = AutoDisposeProviderRef<RideRepository>;
String _$pendingRidesHash() => r'7f5ebf1bf64cb3fb47a3fefe3b600700c22f805c';

/// See also [pendingRides].
@ProviderFor(pendingRides)
final pendingRidesProvider =
    AutoDisposeStreamProvider<List<RideModel>>.internal(
  pendingRides,
  name: r'pendingRidesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pendingRidesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingRidesRef = AutoDisposeStreamProviderRef<List<RideModel>>;
String _$activeRideHash() => r'c748ee0264c9532aa8dc988f30e7de007aa7bb12';

/// See also [activeRide].
@ProviderFor(activeRide)
final activeRideProvider = AutoDisposeStreamProvider<RideModel?>.internal(
  activeRide,
  name: r'activeRideProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeRideHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveRideRef = AutoDisposeStreamProviderRef<RideModel?>;
String _$myPastTripsHash() => r'cc7a4640cb085d822afbfc5cb1c0fe46b64ac6e9';

/// See also [myPastTrips].
@ProviderFor(myPastTrips)
final myPastTripsProvider = AutoDisposeStreamProvider<List<RideModel>>.internal(
  myPastTrips,
  name: r'myPastTripsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myPastTripsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyPastTripsRef = AutoDisposeStreamProviderRef<List<RideModel>>;
String _$activeRideIdHash() => r'8e3b64b0ed5ee0d07d89cae42e7cb0e943739529';

/// See also [ActiveRideId].
@ProviderFor(ActiveRideId)
final activeRideIdProvider =
    AutoDisposeNotifierProvider<ActiveRideId, String?>.internal(
  ActiveRideId.new,
  name: r'activeRideIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeRideIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveRideId = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
