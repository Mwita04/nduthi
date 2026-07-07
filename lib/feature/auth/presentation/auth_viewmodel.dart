import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;
  String? _userName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;
  String? get userRole => _userRole;
  String? get userName => _userName;
  bool get hasSelectedRole => _userRole != null && _userRole!.isNotEmpty;

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        _userRole = doc.data()!['role'];
        _userName = doc.data()!['name'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await loadUserData();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': fullName.trim(),
        'email': email.trim(),
        'role': null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _userName = fullName.trim();
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'We could not create your account right now.';
      debugPrint('Error creating account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'Please sign in again before choosing a role.';
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'role': role,
      }, SetOptions(merge: true));
      _userRole = role;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Unable to save your role right now. Please try again.';
      debugPrint('Error saving role: $e');
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userRole = _userName = null;
    notifyListeners();
  }
}
