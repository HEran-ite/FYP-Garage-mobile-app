# 🚗 GarageUp

A Flutter mobile application for garage/service management built with Clean Architecture principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Development Guidelines](#development-guidelines)
- [Contributing](#contributing)

## 🎯 Overview

GarageUp is a comprehensive garage management application that helps garage owners manage their business operations, including appointments, services, and customer interactions. The application is built using Flutter and follows Clean Architecture principles to ensure scalability, maintainability, and testability.

## 🏗️ Architecture

This project follows **Clean Architecture** with a **feature-first modular structure**:

### Architecture Layers

1. **Presentation Layer** (`presentation/`)
   - UI components (pages, widgets)
   - State management using BLoC pattern
   - No business logic

2. **Domain Layer** (`domain/`)
   - Business logic and entities
   - Repository interfaces
   - Use cases
   - Framework-independent

3. **Data Layer** (`data/`)
   - Data models (JSON serializable)
   - Data sources (remote/local)
   - Repository implementations

### Core Principles

- ✅ **Loose Coupling**: Features are independent and self-contained
- ✅ **High Cohesion**: Related functionality is grouped together
- ✅ **Separation of Concerns**: Each layer has a single responsibility
- ✅ **Dependency Inversion**: Domain layer doesn't depend on data layer
- ✅ **Scalability**: Easy to add new features without refactoring

## ✨ Features

### Current Features

- **Dashboard**: Overview of garage activity, statistics, and quick actions
- **Appointments**: Booking management, appointment listing, and details
- **Services**: Garage services management (create, update, list)
- **Profile**: Garage owner profile and garage information management

### Future Features

The architecture supports easy addition of new features such as:
- Authentication & Authorization
- Notifications
- Customer Management
- Inventory Management
- Reports & Analytics

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS development tools (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd garage
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Setup

1. **Add dependencies** to `pubspec.yaml` (if not already added):
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

2. **Configure API endpoints** in `lib/core/constants/api_constants.dart`

3. **Set up dependency injection** in `lib/injection/injection_container.dart`

4. **Configure routing** in `lib/core/routing/app_router.dart`

## 📁 Project Structure

```
lib/
├── core/                    # App-wide infrastructure
│   ├── constants/          # Centralized constants
│   ├── theme/              # Theme configuration
│   ├── widgets/            # Reusable UI components
│   ├── error/              # Error handling
│   ├── network/            # API client setup
│   ├── utils/              # Helper functions
│   └── routing/             # GoRouter configuration
│
├── features/               # Feature modules
│   ├── dashboard/          # Dashboard feature
│   ├── appointments/       # Appointments feature
│   ├── services/           # Services feature
│   └── profile/            # Profile feature
│
└── injection/              # Dependency injection
```

Each feature follows the same structure:
- `presentation/` - UI and state management (BLoC)
- `domain/` - Business logic (entities, repositories, use cases)
- `data/` - Data layer (models, data sources, repository implementations)

For detailed structure, see [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md).

## 📦 Dependencies

### Core Dependencies

- **flutter_bloc**: State management using BLoC pattern
- **equatable**: Value equality for Dart objects
- **dartz**: Functional programming in Dart (Either, Option)
- **go_router**: Declarative routing for Flutter
- **get_it**: Service locator for dependency injection
- **dio**: HTTP client for API calls

## 💻 Development Guidelines

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write self-documenting code with clear comments where needed
- Keep functions small and focused

### Architecture Rules

1. **No Hardcoded Values**: Use constants from `core/constants/`
2. **No Business Logic in UI**: All business logic goes in use cases
3. **BLoC for State Management**: Use BLoC pattern for all state management
4. **Repository Pattern**: All data access goes through repositories
5. **Dependency Injection**: Use dependency injection for all dependencies

### Adding a New Feature

1. Create a new folder under `lib/features/`
2. Follow the Clean Architecture structure:
   ```
   feature_name/
   ├── presentation/
   │   ├── pages/
   │   ├── widgets/
   │   └── bloc/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── data/
       ├── models/
       ├── datasources/
       └── repositories/
   ```
3. Add routes in `core/routing/app_router.dart`
4. Register dependencies in `injection/injection_container.dart`

### Testing

- Write unit tests for use cases
- Write widget tests for UI components
- Write integration tests for features
- Aim for high test coverage

## 🤝 Contributing

1. Create a feature branch from `main`
2. Follow the architecture and coding guidelines
3. Write tests for new features
4. Update documentation as needed
5. Submit a pull request with a clear description

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 📄 License

[Add your license here]

---

**Built with ❤️ using Flutter and Clean Architecture**
