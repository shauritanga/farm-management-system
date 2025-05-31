# Authentication Feature

This feature implements a comprehensive authentication system for the Agripoa agricultural platform, supporting both individual farmers and cooperative users with different access levels.

## Architecture

The authentication feature follows clean architecture principles with three layers:

### Domain Layer (`domain/`)
- **Entities**: 
  - `UserEntity` - Core user business object with support for farmer and cooperative user types
  - `UserType` enum - Farmer vs Cooperative user types
  - `UserStatus` enum - Account status management
- **Repositories**: `AuthRepository` - Abstract contracts for authentication operations
- **Use Cases**: Business logic for authentication operations
  - `LoginUsecase` - User login with validation
  - `RegisterFarmerUsecase` - Farmer self-registration with comprehensive validation
  - `GetCurrentUserUsecase` - Retrieve current authenticated user
  - `LogoutUsecase` - User logout
  - `ResetPasswordUsecase` - Password reset functionality

### Data Layer (`data/`)
- **Models**: `UserModel` - Data transfer objects with Firestore serialization
- **Data Sources**: `RemoteAuthDataSource` - Firebase Auth and Firestore integration
- **Repositories**: `AuthRepositoryImpl` - Concrete implementation of auth operations

### Presentation Layer (`presentation/`)
- **Screens**: 
  - `LoginScreen` - User login interface
  - `RegisterScreen` - Farmer registration interface
- **States**: Authentication state management classes
- **Providers**: Riverpod state management providers

## User Types

### Individual Farmers
- **Self-Registration**: Can register themselves through the app
- **Profile Fields**: Name, email, phone, farm details, crop types
- **Access**: Full access to farmer-specific features
- **Validation**: Comprehensive input validation and email verification

### Cooperative Users
- **Admin-Managed**: Cannot self-register, accounts created by administrators
- **Profile Fields**: Name, email, cooperative details, role, permissions
- **Access**: Role-based access to cooperative management features
- **Permissions**: Granular permission system for different cooperative functions

## Features

### Authentication Flow
1. **Onboarding** → **Login Screen** → **Home** (authenticated)
2. **Registration** → **Login Screen** → **Home** (new farmers)
3. **Forgot Password** → **Email Reset** → **Login Screen**

### Security Features
- **Firebase Authentication**: Secure authentication backend
- **Input Validation**: Comprehensive client-side validation
- **Password Strength**: Enforced strong password requirements
- **Email Verification**: Built-in email verification system
- **Session Management**: Automatic session handling

### User Experience
- **Responsive Design**: Scales perfectly across all device sizes using flutter_screenutil
- **Loading States**: Beautiful loading indicators and progress feedback
- **Error Handling**: User-friendly error messages and recovery options
- **Form Validation**: Real-time validation with helpful error messages
- **Agricultural Theming**: Consistent with agricultural platform design

## State Management

Uses Riverpod for state management with the following providers:

### Core Providers
- `authProvider` - Main authentication state
- `loginProvider` - Login form state
- `registrationProvider` - Registration form state
- `passwordResetProvider` - Password reset state

### Use Case Providers
- `loginUsecaseProvider` - Login business logic
- `registerFarmerUsecaseProvider` - Registration business logic
- `getCurrentUserUsecaseProvider` - User retrieval logic

## Data Persistence

### Firebase Firestore Schema
```
users/{userId}
├── id: string
├── name: string
├── email: string
├── userType: 'farmer' | 'cooperative'
├── status: 'active' | 'inactive' | 'suspended' | 'pending'
├── phoneNumber?: string
├── profileImageUrl?: string
├── createdAt: timestamp
├── lastLoginAt?: timestamp
├── farmName?: string (farmers only)
├── farmLocation?: string (farmers only)
├── farmSize?: number (farmers only)
├── cropTypes?: string[] (farmers only)
├── cooperativeId?: string (cooperative users only)
├── cooperativeName?: string (cooperative users only)
├── role?: string (cooperative users only)
└── permissions?: string[] (cooperative users only)
```

## Usage

### Navigation Integration
```dart
// After onboarding completion
context.go('/login');

// After successful authentication
context.go('/home');

// Registration flow
context.push('/register');
```

### State Listening
```dart
// Listen to authentication state changes
ref.listen<AuthState>(authProvider, (previous, next) {
  if (next is AuthAuthenticated) {
    // User is authenticated
    final user = next.user;
    if (user.isFarmer) {
      // Handle farmer user
    } else if (user.isCooperative) {
      // Handle cooperative user
    }
  }
});
```

### User Type Checking
```dart
final user = ref.watch(authProvider);
if (user is AuthAuthenticated) {
  if (user.user.isFarmer) {
    // Show farmer-specific UI
  } else if (user.user.isCooperative) {
    // Show cooperative-specific UI
    if (user.user.hasPermission('manage_farmers')) {
      // Show management features
    }
  }
}
```

## Validation Rules

### Registration Validation
- **Name**: Minimum 2 characters, required
- **Email**: Valid email format, unique, required
- **Password**: Minimum 6 characters, must contain letter and number, required
- **Phone**: Valid phone format (optional)
- **Farm Size**: Positive number (optional)

### Login Validation
- **Email**: Valid email format, required
- **Password**: Minimum 6 characters, required

## Error Handling

### User-Friendly Messages
- "Email already exists" → "An account with this email already exists"
- "weak-password" → "Password is too weak"
- "user-not-found" → "No user found with this email"
- "wrong-password" → "Incorrect password"

### Recovery Options
- **Forgot Password**: Email-based password reset
- **Account Issues**: Clear guidance for contacting support
- **Network Errors**: Retry mechanisms and offline handling

## Testing

The authentication feature includes comprehensive test coverage:
- Unit tests for use cases and validation logic
- Widget tests for UI components
- Integration tests for authentication flows

## Security Considerations

- **Firebase Security Rules**: Proper Firestore security rules implementation
- **Input Sanitization**: All user inputs are validated and sanitized
- **Session Security**: Secure session management with automatic expiration
- **Permission Checks**: Server-side permission validation for cooperative users
