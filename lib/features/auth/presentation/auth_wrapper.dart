import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import '../../home/presentation/home_screen.dart';
import 'role_selection_screen.dart';

/// The root-level widget that determines which screen to show based on Auth state.
/// 
/// It acts as a router that reacts to:
/// 1. Firebase Authentication state (Logged in vs Logged out)
/// 2. Firestore Profile state (Role selected vs No role selected)
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user != null) {
          // If logged in, we check if the user has completed their profile (selected a role).
          final profileState = ref.watch(userProfileProvider);
          
          return profileState.when(
            data: (profile) {
              // If no role is found in Firestore, force the Role Selection screen.
              if (profile == null || profile.role == null) {
                return const RoleSelectionScreen();
              }
              // If profile and role exist, take them to the main Home dashboard.
              return const HomeScreen();
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Scaffold(
              body: Center(child: Text('Profile Error: $e')),
            ),
          );
        }
        // If not logged in, show the Login/Signup screen.
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Auth Error: $e')),
      ),
    );
  }
}
