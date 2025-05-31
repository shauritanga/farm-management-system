# Agripoa Theme System

A comprehensive theme system built with FlexColorScheme following Material Design 3 principles and agricultural design language.

## Overview

The theme system provides:
- **Light and Dark Modes** with automatic system detection
- **Agricultural Color Palette** optimized for farming applications
- **Consistent Typography** with proper hierarchy and accessibility
- **Custom Theme Extensions** for agricultural-specific colors and spacing
- **State Management** with Riverpod for theme persistence
- **UI/UX Best Practices** following Material Design 3 guidelines

## Color Palette

### Primary Colors
- **Primary Green** (`#00623A`) - Deep forest green for primary actions
- **Secondary Green** (`#02B729`) - Vibrant green for secondary actions  
- **Accent Green** (`#4DAC85`) - Muted green for accents and highlights
- **Success Green** (`#00D27D`) - Success states and positive actions

### Supporting Colors
- **Primary Blue** (`#37B7FF`) - Information and links
- **Pure White** (`#FFFFFF`) - Clean backgrounds
- **Rich Black** (`#181818`) - Text and dark themes

### Agricultural Data Colors
- **Crop Health Good** - Success green for healthy crops
- **Crop Health Warning** - Orange for warning states
- **Crop Health Poor** - Red for poor conditions
- **Soil Moisture** - Blue for water-related data
- **Temperature** - Orange for temperature readings
- **Rainfall** - Blue for precipitation data

## Architecture

### Core Files

```
lib/core/theme/
├── app_colors.dart          # Color palette definitions
├── app_theme.dart           # FlexColorScheme configuration
├── app_typography.dart      # Typography system
├── theme_extensions.dart    # Custom theme extensions
├── theme_provider.dart      # Riverpod state management
├── widgets/
│   └── theme_selector.dart  # Theme selection components
└── screens/
    └── theme_demo_screen.dart # Theme showcase
```

### Theme Provider

Uses Riverpod for state management:

```dart
// Watch current theme mode
final themeMode = ref.watch(currentThemeModeProvider);

// Check if dark mode is active
final isDarkMode = ref.watch(isDarkModeProvider);

// Change theme
ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
```

### Custom Extensions

Access agricultural colors and spacing:

```dart
final theme = Theme.of(context);
final agriculturalColors = theme.agriculturalColors;
final spacing = theme.spacing;

// Use agricultural colors
Container(
  color: agriculturalColors.cropHealthGood,
  child: Text('Healthy Crop'),
)

// Use consistent spacing
Padding(
  padding: EdgeInsets.all(spacing.md),
  child: child,
)
```

## Usage

### Basic Implementation

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: MyHomePage(),
    );
  }
}
```

### Theme Selection

```dart
// Simple toggle button
ThemeToggleButton()

// Full theme selector
ThemeSelector()

// Bottom sheet selector
ThemeSelectorBottomSheet.show(context)
```

### Agricultural Data Display

```dart
_DataCard(
  title: 'Soil Moisture',
  value: '65%',
  color: theme.agriculturalColors.soilMoisture,
  icon: Icons.water_drop,
)
```

## Features

### Accessibility
- **WCAG AA Compliant** color contrasts
- **Proper Text Scaling** with relative font sizes
- **Touch Target Sizes** meeting accessibility guidelines
- **Screen Reader Support** with semantic labels

### Responsive Design
- **Adaptive Layouts** for different screen sizes
- **Flexible Spacing** system for consistent margins/padding
- **Scalable Typography** that adapts to user preferences

### Performance
- **Efficient State Management** with Riverpod
- **Optimized Theme Switching** with minimal rebuilds
- **Cached Preferences** for instant theme restoration

### Developer Experience
- **Type-Safe Colors** with custom extensions
- **Consistent API** across all components
- **Easy Customization** through centralized configuration
- **Comprehensive Documentation** with examples

## Customization

### Adding New Colors

```dart
// In app_colors.dart
static const Color newColor = Color(0xFF123456);

// In theme_extensions.dart
class AgriculturalColors extends ThemeExtension<AgriculturalColors> {
  final Color newColor;
  // Add to constructor and methods
}
```

### Modifying Typography

```dart
// In app_typography.dart
static TextStyle get customStyle => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  // Add custom properties
);
```

### Theme Configuration

```dart
// In app_theme.dart
static ThemeData get lightTheme {
  return FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: AppColors.primaryGreen,
      // Modify color scheme
    ),
    // Customize other properties
  );
}
```

## Best Practices

### Color Usage
- Use **primary green** for main actions (CTAs, FABs)
- Use **secondary green** for secondary actions
- Use **accent green** for highlights and accents
- Use **agricultural colors** for data visualization
- Maintain **sufficient contrast** for accessibility

### Typography
- Use **Poppins** for headings and titles
- Use **Inter** for body text and UI elements
- Use **Roboto Mono** for data and code
- Follow **Material Design 3** typography scale

### Spacing
- Use **consistent spacing** from the spacing system
- Apply **8dp grid** for layout alignment
- Maintain **proper touch targets** (minimum 44dp)
- Use **semantic spacing** (xs, sm, md, lg, xl, xxl)

### State Management
- **Persist theme preferences** across app sessions
- **React to system theme changes** when in system mode
- **Provide smooth transitions** between theme modes
- **Handle edge cases** gracefully

## Dependencies

- `flex_color_scheme: ^8.2.0` - Advanced theming
- `flutter_riverpod: ^2.6.1` - State management
- `google_fonts: ^6.2.1` - Typography
- `shared_preferences: ^2.3.3` - Persistence

## Demo

Visit `/theme-demo` route to see the complete theme system in action, including:
- Color palette showcase
- Typography examples
- Component demonstrations
- Agricultural data visualization
- Interactive theme switching
