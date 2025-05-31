# Onboarding Feature

This feature implements a comprehensive onboarding flow for the Agripoa agricultural platform, following clean architecture principles.

## Architecture

The onboarding feature follows the established clean architecture pattern with three layers:

### Domain Layer (`domain/`)
- **Entities**: `OnboardingPageEntity` - Core business objects
- **Repositories**: `OnboardingRepository` - Abstract contracts for data access
- **Use Cases**: Business logic for onboarding operations
  - `GetOnboardingPagesUsecase` - Retrieves onboarding pages
  - `CheckOnboardingStatusUsecase` - Checks if user completed onboarding
  - `CompleteOnboardingUsecase` - Marks onboarding as completed

### Data Layer (`data/`)
- **Models**: `OnboardingPageModel` - Data transfer objects
- **Data Sources**: `LocalOnboardingDataSource` - Local storage implementation
- **Repositories**: `OnboardingRepositoryImpl` - Repository implementation

### Presentation Layer (`presentation/`)
- **Screens**: `OnboardingScreen` - Main onboarding UI
- **Widgets**: `OnboardingPageWidget` - Individual page component
- **Providers**: Riverpod state management
- **States**: State classes for UI state management

## Features

### Three Onboarding Screens

1. **Farm Management** (Screen 1)
   - Title: "Manage Your Farm Efficiently"
   - Description: Track crops, monitor growth stages, manage livestock
   - Illustration: High-quality agricultural farming image from Unsplash
   - Fallback Icon: Agriculture icon

2. **Cooperative Management** (Screen 2)
   - Title: "Cooperative Management Made Easy"
   - Description: Manage farmers, track sales, monitor production
   - Illustration: Farmers working together/cooperative scene
   - Fallback Icon: Groups icon

3. **Get Started** (Screen 3)
   - Title: "Start Your Agricultural Journey"
   - Description: Join thousands of farmers and cooperatives in Tanzania
   - Illustration: Successful harvest/agricultural journey scene
   - Fallback Icon: Rocket launch icon
   - Button: "Get Started"

### Navigation Features

- **Page Indicators**: Smooth animated dots showing current page
- **Navigation Controls**: Back/Next buttons with smooth transitions
- **Skip Option**: Skip button available on first two pages
- **Completion**: Automatic navigation to auth screen after completion

### State Management

Uses Riverpod for state management with the following providers:
- `onboardingProvider` - Main state notifier
- `onboardingRepositoryProvider` - Repository provider
- `localOnboardingDataSourceProvider` - Data source provider

### Persistence

Onboarding completion status is persisted using SharedPreferences:
- Key: `onboarding_completed`
- Value: `true` when completed, `false` or null when not completed

## Usage

### Integration

The onboarding feature is integrated into the app router:
1. Splash screen checks onboarding status
2. If not completed, navigates to `/onboarding`
3. If completed, navigates to `/auth`

### Testing

Unit tests are provided in `test/features/onboarding/onboarding_test.dart` covering:
- Page count and content validation
- Order verification
- Button text validation
- Image path validation

### Customization

To customize onboarding content, modify the data in `LocalOnboardingDataSource.getOnboardingPages()`:

```dart
const OnboardingPageModel(
  id: '1',
  title: 'Your Custom Title',
  description: 'Your custom description',
  imagePath: 'assets/images/your_image.png',
  order: 1,
),
```

### Image System

The onboarding screens now use high-quality cached network images:

#### Features
- **CachedNetworkImage**: Efficient image loading and caching
- **Progressive Loading**: Shows loading progress with percentage
- **Fallback Icons**: Beautiful fallback when images fail to load
- **Optimized Caching**: Memory and disk cache configuration
- **Smooth Animations**: Fade-in effects for better UX

#### Image Sources
- **Farm Management**: Modern farming with technology illustration
- **Cooperative Management**: Farmers working together scene
- **Agricultural Journey**: Successful harvest/farming scene

#### Loading States
1. **Loading Placeholder**: Animated loading indicator with progress
2. **Progress Indicator**: Shows download percentage and data size
3. **Error Fallback**: Elegant fallback with themed icons and messaging
4. **Success State**: Smooth fade-in animation

#### Performance Optimizations
- **Memory Cache**: 800x600 optimized resolution
- **Disk Cache**: Persistent storage for offline viewing
- **Lazy Loading**: Images load only when needed
- **Compression**: Optimized image quality and size

## Dependencies

- `flutter_riverpod` - State management
- `shared_preferences` - Local storage
- `smooth_page_indicator` - Page indicators
- `go_router` - Navigation
- `google_fonts` - Typography
- `cached_network_image` - Image loading and caching

## File Structure

```
lib/features/onboarding/
├── data/
│   ├── datasources/
│   │   └── local_onboarding_datasource.dart
│   ├── models/
│   │   └── onboarding_page_model.dart
│   └── repositories/
│       └── onboarding_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── onboarding_page.dart
│   ├── repositories/
│   │   └── onboarding_repository.dart
│   └── usecases/
│       ├── check_onboarding_status_usecase.dart
│       ├── complete_onboarding_usecase.dart
│       └── get_onboarding_pages_usecase.dart
└── presentation/
    ├── providers/
    │   └── onboarding_provider.dart
    ├── screens/
    │   └── onboarding_screen.dart
    ├── states/
    │   └── onboarding_state.dart
    └── widgets/
        └── onboarding_page_widget.dart
```
