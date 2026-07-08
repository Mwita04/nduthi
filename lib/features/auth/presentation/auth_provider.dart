import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository();
}

@riverpod
Stream<UserModel?> userProfile(UserProfileRef ref) {
  final user = ref.watch(authStateProvider).value;
  
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? UserModel.fromMap(snapshot.data()!) : null);
}

@riverpod
String? userRole(UserRoleRef ref) {
  return ref.watch(userProfileProvider).value?.role;
}
