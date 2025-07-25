# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development
- `flutter run` - Run the app in development mode
- `flutter run -d chrome` - Run on web browser for testing
- `flutter build android` - Build APK for Android
- `flutter build ios` - Build for iOS (requires macOS)
- `flutter build web` - Build for web deployment
- `flutter clean` - Clean build artifacts when encountering issues

### Testing & Analysis
- `flutter test` - Run all tests (note: currently contains default counter test that needs updating)
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter analyze` - Run static analysis (uses analysis_options.yaml with flutter_lints)
- `flutter pub get` - Install dependencies after pubspec.yaml changes
- `flutter pub upgrade` - Update dependencies to latest compatible versions

### Localization
- `flutter gen-l10n` - Generate localization files (if ARB files are modified)

### Firebase Configuration
Firebase is required for authentication and user management:
- Android: `android/app/google-services.json` must be present
- iOS: `ios/Runner/GoogleService-Info.plist` must be present
- Web: Firebase config is in `lib/firebase_options.dart`
- Project ID: "car-selling-flutter-app"

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
- New users automatically get 'customer' role unless promoted by admin
- AuthProvider methods: authenticate(), logout(), resetPassword(), promoteToStaff(), updateUserRole(), addStaffUser()

**Routing & Navigation**:
- Named routes defined in main.dart with route protection based on user roles
- App starts at '/splash' route which handles authentication state
- Customer routes: '/', '/login', '/forgot-password', '/car-details'
- Staff/admin routes: '/staff-home', '/home-menu', '/park', '/barrel', '/transport', '/sell', '/tracking', '/user-management', '/add-staff'
- Role-based navigation: customers see limited features, staff/admin see management tools

**Internationalization**:
- Supports English ('en') and French ('fr') locales
- ARB files in lib/l10n/: app_en.arb, app_fr.arb
- Auto-generated localization classes in lib/l10n/
- Language toggle widget available throughout app
- Uses flutter_localizations and intl packages

### Screen Organization
- **Customer screens**: customer_home_screen, car_details_screen, login_screen, forgot_password_screen
- **Staff screens**: staff_home_screen, home_menu, park_car_screen, send_barrel_screen, transport_car_screen, sell_cars_screen, tracking_screen, staff_car_management_screen
- **Admin screens**: user_management_screen, add_staff_screen
- **Common screens**: splash_screen, settings_screen

### Business Logic
The app provides four main services:
1. **Car Parking Service** - Generate receipts for parked cars with owner/vehicle details
2. **Barrel Shipping Service** - Handle barrel shipments to Guinea with sender/receiver info
3. **Car Transport Service** - Manage car transport to Guinea with vehicle details
4. **Car Sales Service** - Browse and contact sellers for available cars

### Database Structure
- Firebase Firestore with 'users' collection for role-based access control
- User document fields: email, role ('customer'|'staff'|'admin'), createdAt, updatedAt
- No additional collections defined yet - business data likely stored elsewhere or TBD

### Key Dependencies
Critical packages:
- `firebase_core: ^3.14.0`, `firebase_auth: ^5.6.0`, `cloud_firestore: ^5.6.9` - Firebase backend
- `provider: ^6.1.2` - State management architecture
- `flutter_localizations` + `intl: ^0.20.2` - Internationalization support
- `pdf: ^3.11.3`, `printing: ^5.13.1` - Receipt/document generation
- `webview_flutter: ^4.7.0` - In-app web content
- `url_launcher: ^6.2.6` - External links (WhatsApp, calls)
- `flutter_bloc: ^8.1.5` - Listed but not used (Provider pattern used instead)

### Development Notes
- Uses Material 3 design with deep orange color scheme
- Multi-platform support: Android, iOS, Web, Windows, macOS, Linux
- Test file needs updating - currently contains default Flutter counter test
- Analysis options use flutter_lints package for code quality