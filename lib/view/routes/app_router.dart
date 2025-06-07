import 'package:go_router/go_router.dart';
import 'package:my_web/view/pages/home_screen.dart';
import 'package:my_web/view/pages/room_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (ctx, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/room/:url',
        builder: (ctx, state) {
          final roomUrl = state.pathParameters['url']!;
          return RoomDetailScreen(roomUrl: roomUrl);
        },
      ),
    ],
  );
}