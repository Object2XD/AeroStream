import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_routes.dart';
import '../../screens/home_screen.dart';
import '../../screens/library/album_detail_screen.dart';
import '../../screens/info/information_screen.dart';
import '../../screens/info/google_drive/google_drive_settings_screen.dart';
import '../../screens/info/listening_time_screen.dart';
import '../../screens/info/songs_played_screen.dart';
import '../../screens/library_screen.dart';
import '../../screens/player/player_screen.dart';
import '../../screens/player/queue_screen.dart';
import '../../screens/playlists_screen.dart';
import '../../widgets/aero_shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _libraryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _playlistsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'playlists',
);
final _infoNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'info');

GoRouter buildAppRouter(Ref ref, {String initialLocation = AppRoutes.home}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.root, redirect: (_, _) => AppRoutes.home),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.player,
        pageBuilder: (context, state) =>
            _buildOverlayPage(state, const PlayerScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.queue,
        pageBuilder: (context, state) =>
            _buildOverlayPage(state, const QueueScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => _buildBranchShell(0, child),
                routes: [
                  GoRoute(
                    path: AppRoutes.home,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: HomeScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _libraryNavigatorKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => _buildBranchShell(1, child),
                routes: [
                  GoRoute(
                    path: AppRoutes.library,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: LibraryScreen()),
                    routes: [
                      GoRoute(
                        path: 'album/:id',
                        pageBuilder: (context, state) => MaterialPage<void>(
                          child: AlbumDetailScreen(
                            albumId: state.pathParameters['id'] ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _playlistsNavigatorKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => _buildBranchShell(2, child),
                routes: [
                  GoRoute(
                    path: AppRoutes.playlists,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: PlaylistsScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _infoNavigatorKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => _buildBranchShell(3, child),
                routes: [
                  GoRoute(
                    path: AppRoutes.info,
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: InformationScreen()),
                    routes: [
                      GoRoute(
                        path: 'google-drive',
                        pageBuilder: (context, state) =>
                            const MaterialPage<void>(
                              child: GoogleDriveSettingsScreen(),
                            ),
                      ),
                      GoRoute(
                        path: 'listening-time',
                        pageBuilder: (context, state) =>
                            const MaterialPage<void>(
                              child: ListeningTimeScreen(),
                            ),
                      ),
                      GoRoute(
                        path: 'songs-played',
                        pageBuilder: (context, state) =>
                            const MaterialPage<void>(
                              child: SongsPlayedScreen(),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return buildAppRouter(ref);
});

Widget _buildBranchShell(int currentNavIndex, Widget child) {
  return AeroShellScaffold(
    currentNavIndex: currentNavIndex,
    padBodyForBottomChrome: false,
    body: child,
  );
}

CustomTransitionPage<void> _buildOverlayPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    child: child,
  );
}
