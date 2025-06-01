import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_web/view/pages/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes : <GoRoute> [
      GoRoute(
        path: '/',
        builder: (ctx, state ) => const HomeScreen(),
      ),
      GoRoute(
        path: '/room/:url',
        builder: (ctx, state){
          final roomUrl = state.pathParameters['url'];
          
          //todo : 이거 페이지 만들어야 함. 
          return Text('Room Detail Page for: $roomUrl'); // Placeholder
        }

      )
    ]
  );
}