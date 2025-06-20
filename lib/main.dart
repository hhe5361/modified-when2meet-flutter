import 'package:flutter/material.dart';
import 'package:my_web/view_model/notice_view_model.dart';
import 'package:my_web/view_model/room_detail_view_model.dart';
import 'package:my_web/view_model/session_service.dart';
import 'package:provider/provider.dart';
import 'package:my_web/core/theme/app_theme.dart';
import 'package:my_web/view_model/home_view_model.dart';
import 'package:my_web/view/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
        create: (context) => RoomDetailViewModel(context.read<SessionService>())),
        ChangeNotifierProvider(
        create: (context) => NoticeViewModel(context.read<SessionService>())),
      ],
      child: MaterialApp.router(
        title: "When2Meet",
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}