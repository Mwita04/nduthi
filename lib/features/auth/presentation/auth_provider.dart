import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

/// Provider for the Firebase Auth state.
/// Listens to [authStateChanges] and emits the current [User] or null.
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for the [UserRepository] instance.
final userRepositoryProvider = Provider((ref) => UserRepository());

/// Stream provider for the authenticated user's profile data from Firestore.
/// 
/// This provider watches the [authProvider] and automatically switches to
/// the corresponding Firestore document stream when the user logs in.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authProvider).value;
  
  // If no user is logged in, emit null immediately.
  if (authState == null) return Stream.value(null);
  
  // Return a real-time stream of the user's document from the 'users' collection.
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authState.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? UserModel.fromMap(snapshot.data()!) : null);
});

/// A simplified provider to get the current user's role.
/// 
/// It derives its value from the [userProfileProvider].
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).value?.role;
});
