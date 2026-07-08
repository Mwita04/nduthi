import 'package:cloud_firestore/cloud_firestore.dart';

enum RideStatus {
  pending,
  accepted,
  ongoing,
  completed,
  cancelled
}

class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final String pickupAddress;
  final String destinationAddress;
  final GeoPoint pickupLocation;
  final GeoPoint destinationLocation;
  final double fare;
  final RideStatus status;
  final DateTime createdAt;

  RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.fare,
    this.status = RideStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'fare': fare,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map, String id) {
    return RideModel(
      id: id,
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'],
      pickupAddress: map['pickupAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      pickupLocation: map['pickupLocation'] as GeoPoint,
      destinationLocation: map['destinationLocation'] as GeoPoint,
      fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
      status: RideStatus.values.byName(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
