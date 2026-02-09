import 'package:flutter/material.dart';

// TODO: Import routing, theme, and dependency injection
// import 'package:garage/core/routing/app_router.dart';
// import 'package:garage/core/theme/app_theme.dart';
// import 'package:garage/injection/injection_container.dart';

void main() {
  // TODO: Initialize dependency injection
  // setupDependencyInjection();

  runApp(const GarageUpApp());
}

class GarageUpApp extends StatelessWidget {
  const GarageUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Configure with GoRouter and app theme
    return MaterialApp(
      title: 'GarageUp',
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // routerConfig: AppRouter.router,
      home: const Scaffold(
        body: Center(child: Text('GarageUp - Clean Architecture Setup')),
      ),
    );
  }
}
