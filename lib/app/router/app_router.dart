import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/collections/presentation/collections_screen.dart';
import '../../features/collections/presentation/collection_details_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/collections',
        builder: (context, state) => const CollectionsScreen(),
      ),
      GoRoute(
        path: '/collections/:id',
        builder: (context, state) => CollectionDetailsScreen(
          collectionId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
