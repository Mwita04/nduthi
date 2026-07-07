import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// This is required for Riverpod code generation.
// After running 'dart run build_runner build', Riverpod will automatically generate the 'auth_provider.g.dart' file.
part '../../../feature/auth/presentation/auth_provider.g.dart';

/// The authProvider exposes a continuous Stream of the current user's authentication state.
///
/// How it works:
/// - Returns [User] object if a user is currently signed in.
/// - Returns [null] if no user is signed in.
/// - Automatically emits updates when the user signs in or signs out.
@riverpod
Stream<User?> auth(AuthRef ref) {
  // Access the singleton instance of Firebase Authentication.
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  // authStateChanges() is a built-in Firebase stream that fires events
  // immediately upon registration, login, or logout.
  return authInstance.authStateChanges();
}
