import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

import 'core/routing/app_router.dart';
import 'core/routing/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env').catchError((_) {});

  // Fix blank map on Android: use Hybrid Composition and warm up Maps SDK
  if (defaultTargetPlatform == TargetPlatform.android) {
    final platform = GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      final android = platform;
      android.useAndroidViewSurface = true;
      android.warmup();
    }
  }

  await setupDependencyInjection();

  runApp(const GarageUpApp());
}

class GarageUpApp extends StatelessWidget {
  const GarageUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        title: 'Garage Owner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: RoutePaths.login,
      ),
    );
  }
}
