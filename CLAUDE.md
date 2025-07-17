# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development
- `flutter run` - Run the app in development mode
- `flutter build android` - Build APK for Android
- `flutter build ios` - Build for iOS (requires macOS)
- `flutter build web` - Build for web deployment

### Testing & Analysis
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis (uses analysis_options.yaml)
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies

### Firebase
- Ensure Firebase is properly configured before running
- Android: `android/app/google-services.json` must be present
- iOS: `ios/Runner/GoogleService-Info.plist` must be present

## Architecture Overview

### Core Structure
This is a Flutter business services application with Firebase backend integration supporting multiple user roles (customer, staff, admin).

### Key Components

**State Management**: 
- Uses Provider pattern with two main providers:
  - `AuthProvider` (lib/providers/auth_provider.dart) - Handles authentication and user role management
  - `LanguageProvider` (lib/providers/language_provider.dart) - Manages English/French localization

**Authentication Flow**:
- Firebase Authentication with email/password
- Role-based access control stored in Firestore 'users' collection
- User roles: customer (default), staff, admin
- Authentication state managed through AuthProvider

**Routing**:
- Named routes defined in main.dart
- Customer routes: splash, login, customer home, car details
- Staff/admin routes: staff home, home menu, park car, send barrel, transport car, sell cars, tracking, user management, add staff

**Localization**:
- Supports English and French languages
- Localization files in lib/l10n/ directory
- Language switching through LanguageProvider

### Screen Organization
- **Customer screens**: customer_home_screen, car_details_screen, login_screen, forgot_password_screen
- **Staff screens**: staff_home_screen, home_menu, park_car_screen, send_barrel_screen, transport_car_screen, sell_cars_screen, tracking_screen, staff_car_management_screen
- **Admin screens**: user_management_screen, add_staff_screen
- **Common screens**: splash_screen, settings_screen

### Database Structure
- Firebase Firestore with 'users' collection
- User documents contain: email, role, createdAt, updatedAt fields
- Role field determines access permissions throughout the app

### Key Dependencies
- firebase_core, firebase_auth, cloud_firestore - Firebase integration
- provider - State management
- flutter_localizations - Internationalization
- pdf, printing - Document generation
- webview_flutter - Web content display
- url_launcher - External URL handling

### Testing
- Basic widget tests in test/widget_test.dart
- Default test structure includes counter increment test (needs updating for actual app functionality)