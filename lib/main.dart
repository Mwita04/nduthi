import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
// Corrected imports pointing precisely to the new plural features folder layout
import 'package:nduthi/features/auth/application/auth_provider.dart';
import 'package:nduthi/features/auth/presentation/login_screen.dart';

void main() async {
  // Guard clause ensuring native communication links are ready before Firebase kicks off
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // ProviderScope houses all Riverpod states globally across the app tree
    const ProviderScope(
      child: MotoRideApp(),
    ),
  );
}

class MotoRideApp extends ConsumerWidget {
  const MotoRideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the auth state stream. Rebuilds automatically on login state changes.
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'MotoRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            // No session active? Move straight to user login interface
            return const LoginScreen();
          }
          return const Scaffold(
            body: Center(child: Text('Home Dashboard Placeholder')),
          );
        },
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Auth Error Encountered: $err')),
        ),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
