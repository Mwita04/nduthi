import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/ride/presentation/ride_confirmation_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoadingAuth = authState.isLoading;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (isLoadingAuth) return null;

      if (!isLoggedIn) {
        return isGoingToLogin ? null : '/login';
      }

      final profile = userProfile.value;
      final isLoadingProfile = userProfile.isLoading;

      if (isLoadingProfile) return null;

      final hasRole = profile != null && profile.role != null;
      final isGoingToRoleSelection = state.matchedLocation == '/role-selection';

      if (!hasRole) {
        return isGoingToRoleSelection ? null : '/role-selection';
      }

      if (isGoingToLogin || isGoingToRoleSelection) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/ride-confirmation',
        builder: (context, state) {
          final args = state.extra as Map<String, String>?;
          return RideConfirmationScreen(
            pickup: args?['pickup'] ?? '',
            destination: args?['destination'] ?? '',
          );
        },
      ),
    ],
  );
});
