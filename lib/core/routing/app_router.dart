import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/appointments/presentation/pages/appointment_list_page.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_event.dart';
import '../../injection/injection_container.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/services/presentation/pages/service_list_page.dart';
import 'route_paths.dart';

/// App routing with named routes
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case RoutePaths.createAccount:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CreateAccountPage(),
        );
      case RoutePaths.dashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DashboardPage(),
        );
      case RoutePaths.appointments:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AppointmentListPage(),
        );
      case RoutePaths.services:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ServiceListPage(),
        );
      case RoutePaths.profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );
      case RoutePaths.notifications:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => sl<NotificationBloc>()..add(const LoadNotifications()),
            child: const NotificationsPage(),
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
    }
  }
}
