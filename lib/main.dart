import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_web/view_model/home_view_model.dart';
import 'package:my_web/view/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: 
    [
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
    ],
    child: MaterialApp.router(
      title : "When2Meet",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter'
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    ),
    );
  }
}