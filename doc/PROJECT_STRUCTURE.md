# GarageUp - Project Structure

This document outlines the Clean Architecture folder structure for the GarageUp Flutter application.

## 📁 Directory Structure

```
lib/
├── core/                          # App-wide infrastructure
│   ├── constants/                 # Centralized constants
│   │   ├── app_constants.dart
│   │   ├── spacing.dart
│   │   ├── font_sizes.dart
│   │   ├── font_weights.dart
│   │   ├── border_radius.dart
│   │   ├── animation_durations.dart
│   │   └── api_constants.dart
│   ├── theme/                      # Theme configuration
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── app_decorations.dart
│   ├── widgets/                    # Reusable UI components
│   │   ├── loading_widget.dart
│   │   └── error_widget.dart
│   ├── error/                      # Error handling
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/                     # Network layer
│   │   └── api_client.dart
│   ├── utils/                       # Helper functions
│   └── routing/                     # Routing configuration
│       ├── app_router.dart
│       └── route_paths.dart
│
├── features/                        # Feature modules
│   ├── dashboard/                   # Dashboard feature
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── dashboard_page.dart
│   │   │   ├── widgets/             # Feature-specific widgets
│   │   │   └── bloc/
│   │   │       ├── dashboard_event.dart
│   │   │       ├── dashboard_state.dart
│   │   │       └── dashboard_bloc.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dashboard_stats.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_dashboard_stats.dart
│   │   └── data/
│   │       ├── models/
│   │       │   └── dashboard_stats_model.dart
│   │       ├── datasources/
│   │       │   └── dashboard_remote_datasource.dart
│   │       └── repositories/
│   │           └── dashboard_repository_impl.dart
│   │
│   ├── appointments/                # Appointments feature
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── appointment_list_page.dart
│   │   │   ├── widgets/
│   │   │   └── bloc/
│   │   │       ├── appointment_event.dart
│   │   │       ├── appointment_state.dart
│   │   │       └── appointment_bloc.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── data/
│   │       ├── models/
│   │       ├── datasources/
│   │       └── repositories/
│   │
│   ├── services/                     # Services feature
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── service_list_page.dart
│   │   │   ├── widgets/
│   │   │   └── bloc/
│   │   │       ├── service_event.dart
│   │   │       ├── service_state.dart
│   │   │       └── service_bloc.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── data/
│   │       ├── models/
│   │       ├── datasources/
│   │       └── repositories/
│   │
│   └── profile/                      # Profile feature
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── profile_page.dart
│       │   ├── widgets/
│       │   └── bloc/
│       │       ├── profile_event.dart
│       │       ├── profile_state.dart
│       │       └── profile_bloc.dart
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── data/
│           ├── models/
│           ├── datasources/
│           └── repositories/
│
└── injection/                        # Dependency injection
    └── injection_container.dart
```

## 🏗️ Architecture Layers

### Core Layer
Contains app-wide infrastructure that supports all features:
- **Constants**: No hardcoded values - all constants centralized
- **Theme**: Colors, text styles, decorations
- **Widgets**: Reusable UI components
- **Error**: Failure and exception classes
- **Network**: API client configuration
- **Routing**: GoRouter setup
- **Utils**: Helper functions

### Feature Layer
Each feature follows Clean Architecture with three layers:

#### Presentation Layer
- **pages/**: Screen widgets
- **widgets/**: Feature-specific reusable widgets
- **bloc/**: State management (events, states, bloc)

#### Domain Layer
- **entities/**: Pure Dart domain models
- **repositories/**: Repository interfaces (abstract)
- **usecases/**: Business logic use cases

#### Data Layer
- **models/**: JSON serializable data models (extend entities)
- **datasources/**: Remote/local data sources
- **repositories/**: Repository implementations

## 📦 Required Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  go_router: ^12.1.3
  get_it: ^7.6.4
  dio: ^5.4.0
```

## 🚀 Next Steps

1. Add dependencies to `pubspec.yaml`
2. Implement API client in `core/network/api_client.dart`
3. Set up dependency injection in `injection/injection_container.dart`
4. Configure routing in `core/routing/app_router.dart`
5. Implement feature-specific business logic
6. Connect UI to BLoCs
7. Add tests for each layer

## 📝 Notes

- All features are self-contained and loosely coupled
- New features can be added by following the same structure
- Domain layer is framework-independent
- Data layer implements domain interfaces
- Presentation layer depends only on domain layer

