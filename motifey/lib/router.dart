import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/player_screen.dart';
import 'screens/playlist_screen.dart';

// 🔥 NEW SCREENS
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';

import 'models/playlist_model.dart';
import 'controller/auth_controller.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,

  /// 🔥 START DI LOGIN
  initialLocation: '/login',

  /// 🔥 AUTH GUARD
  redirect: (context, state) {
    final isLoggedIn = AuthController.instance.isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup';

    /// kalau belum login → paksa ke login
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    /// kalau sudah login tapi masih di login/signup → masuk ke home
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },

  routes: [
    /// 🔐 AUTH ROUTES (DI LUAR SHELL)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    /// 🔥 MAIN APP (SETELAH LOGIN)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // 🔥 TAB HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'playlist',
                  builder: (context, state) {
                    final playlist = state.extra;
                    if (playlist is! Playlist) {
                      return const Scaffold(
                        body: Center(child: Text("Playlist not found")),
                      );
                    }
                    return PlaylistScreen(playlist: playlist);
                  },
                ),
              ],
            ),
          ],
        ),

        // 🔥 TAB SEARCH
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),

        // 🔥 TAB LIBRARY
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
      ],
    ),

    /// 🔥 PROFILE (FULL SCREEN)
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),

    /// 🔥 PLAYER (FULL SCREEN)
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PlayerScreen(),
    ),
  ],
);