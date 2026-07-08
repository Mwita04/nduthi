const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.notifyDriversOnRideRequest = functions.firestore
  .document('rides/{rideId}')
  .onCreate(async (snap, context) => {
    const ride = snap.data();
    if (!ride) return null;

    // Basic implementation: send notification to all drivers with an fcmToken.
    // For production, filter by proximity using geohashes or a geo-index.
    const usersSnapshot = await admin.firestore().collection('users').where('role', '==', 'driver').get();
    const tokens = [];

    usersSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.fcmToken) tokens.push(data.fcmToken);
    });

    if (tokens.length === 0) return null;

    const payload = {
      notification: {
        title: 'New ride request',
        body: `${ride.pickupAddress} → ${ride.destinationAddress}`,
      },
      data: {
        rideId: context.params.rideId,
        passengerId: ride.passengerId,
      },
    };

    try {
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log('Notifications sent', response.successCount);
    } catch (err) {
      console.error('Error sending notifications', err);
    }

    return null;
  });
