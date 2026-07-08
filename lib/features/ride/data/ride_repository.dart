import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/ride_model.dart';

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new ride request in Firestore.
  Future<String> requestRide(RideModel ride) async {
    final docRef = await _firestore.collection('rides').add(ride.toMap());
    return docRef.id;
  }

  /// Streams pending rides for drivers to listen to.
  Stream<List<RideModel>> getPendingRides() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RideModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Updates a ride's status and assigns a driver.
  Future<void> acceptRide(String rideId, String driverId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': RideStatus.accepted.name,
      'driverId': driverId,
    });
  }

  /// Streams a specific ride's updates (for passenger tracking).
  Stream<RideModel?> watchRide(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map((snapshot) => snapshot.exists 
            ? RideModel.fromMap(snapshot.data()!, snapshot.id) 
            : null);
  }

  /// Streams a user's past rides (for trips history).
  Stream<List<RideModel>> getPastRides(String passengerId) {
    return _firestore
        .collection('rides')
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RideModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
