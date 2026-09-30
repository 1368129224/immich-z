import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/session_provider.dart';
import '../screens/album/album_screen.dart';
import '../screens/album/albums_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/library/archive_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/library/trash_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/memories/memories_screen.dart';
import '../screens/people/people_screen.dart';
import '../screens/people/person_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shared/shared_links_screen.dart';
import '../screens/tags/tags_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import '../screens/upload/backup_screen.dart';
import '../screens/viewer/gallery_viewer_screen.dart';
import 'app_shell.dart';

/// Route paths, kept in one place so deep links and in-app navigation agree.
abstract final class AppRoutes {
  static const login = '/login';
  static const timeline = '/';
  static const search = '/search';
  static const albums = '/albums';
  static const album = '/albums/:albumId';
  static const people = '/people';
  static const person = '/people/:personId';
  static const memories = '/memories';
  static const map = '/map';
  static const favorites = '/favorites';
  static const archive = '/archive';
  static const trash = '/trash';
  static const tags = '/tags';
  static const shared = '/shared';
  static const backup = '/backup';
  static const library = '/library';
  static const settings = '/settings';
  static const viewer = '/viewer';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: AppRoutes.timeline,
    // Rebuild navigation whenever login state changes.
    refreshListenable: _SessionListenable(ref),
    redirect: (context, state) {
      final loggedIn = session.isLoggedIn;
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !atLogin) return AppRoutes.login;
      if (loggedIn && atLogin) return AppRoutes.timeline;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timeline,
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.albums,
                builder: (context, state) => const AlbumsScreen(),
                routes: [
                  GoRoute(
                    path: ':albumId',
                    builder: (context, state) => AlbumScreen(
                      albumId: state.pathParameters['albumId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.people,
                builder: (context, state) => const PeopleScreen(),
                routes: [
                  GoRoute(
                    path: ':personId',
                    builder: (context, state) => PersonScreen(
                      personId: state.pathParameters['personId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes above the bottom navigation.
      GoRoute(
        path: AppRoutes.memories,
        builder: (context, state) => const MemoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.archive,
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.trash,
        builder: (context, state) => const TrashScreen(),
      ),
      GoRoute(
        path: AppRoutes.tags,
        builder: (context, state) => const TagsScreen(),
      ),
      GoRoute(
        path: AppRoutes.shared,
        builder: (context, state) => const SharedLinksScreen(),
      ),
      GoRoute(
        path: AppRoutes.backup,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: AppRoutes.viewer,
        builder: (context, state) {
          final ids = state.uri.queryParameters['ids'];
          final index = int.tryParse(
                state.uri.queryParameters['index'] ?? '0',
              ) ??
              0;
          return GalleryViewerScreen(
            assetIds: ids == null || ids.isEmpty
                ? const <String>[]
                : ids.split(','),
            initialIndex: index,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) => const LibraryScreen(),
      ),
    ],
  );
});

/// Bridges the Riverpod session state into `GoRouter.refreshListenable`.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(this._ref) {
    _ref.listen<SessionState>(sessionProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
