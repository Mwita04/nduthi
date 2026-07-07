import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// We import our placeholder home screen using a relative path to avoid compilation errors
import '../../../feature/auth/presentation/home_screen.dart';

/// Why ConsumerWidget?
/// A standard StatelessWidget cannot read Riverpod providers. By changing this
/// to a ConsumerWidget, we gain access to the 'WidgetRef ref' parameter in the build method,
/// which lets us interact with our application state easily.
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to MotoRide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select your account type to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Option 1: Rider (Passenger) Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // TODO: In a later phase, we will save this choice to Firebase Firestore
                  _navigateToHome(context, 'rider');
                },
                child: const Text(
                  'I am a Rider',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // Option 2: Driver (Boda Boda) Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
                onPressed: () {
                  // TODO: In a later phase, we will save this choice to Firebase Firestore
                  _navigateToHome(context, 'driver');
                },
                child: const Text(
                  'I am a Driver',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to handle routing cleanly.
  /// This replaces the old "Provider" logic that caused your undefined identifier errors.
  void _navigateToHome(BuildContext context, String selectedRole) {
    // For now, we simply pass the role to the next screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(userRole: selectedRole),
      ),
    );
  }
}
