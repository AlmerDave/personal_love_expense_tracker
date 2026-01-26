import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

class PesoPalApp extends StatelessWidget {
  const PesoPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PesoPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.dashboard,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
