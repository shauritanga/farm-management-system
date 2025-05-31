import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme_extensions.dart';
import '../widgets/theme_selector.dart';
import '../../utils/responsive_utils.dart';

/// Demo screen to showcase the theme system
class ThemeDemoScreen extends ConsumerWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final agriculturalColors = theme.agriculturalColors;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Selector
            const ThemeSelector(),
            SizedBox(height: ResponsiveUtils.spacing24),

            // Color Palette Section
            _buildSection(
              context,
              'Color Palette',
              _buildColorPalette(theme, agriculturalColors),
            ),
            SizedBox(height: spacing.lg),

            // Typography Section
            _buildSection(context, 'Typography', _buildTypography(theme)),
            SizedBox(height: spacing.lg),

            // Components Section
            _buildSection(
              context,
              'Components',
              _buildComponents(theme, spacing),
            ),
            SizedBox(height: spacing.lg),

            // Agricultural Data Section
            _buildSection(
              context,
              'Agricultural Data',
              _buildAgriculturalData(theme, agriculturalColors),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ThemeSelectorBottomSheet.show(context),
        child: const Icon(Icons.palette),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildColorPalette(
    ThemeData theme,
    AgriculturalColors agriculturalColors,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ColorChip('Primary', theme.colorScheme.primary),
        _ColorChip('Secondary', theme.colorScheme.secondary),
        _ColorChip('Tertiary', theme.colorScheme.tertiary),
        _ColorChip('Surface', theme.colorScheme.surface),
        _ColorChip('Error', theme.colorScheme.error),
        _ColorChip('Crop Health Good', agriculturalColors.cropHealthGood),
        _ColorChip('Crop Health Warning', agriculturalColors.cropHealthWarning),
        _ColorChip('Crop Health Poor', agriculturalColors.cropHealthPoor),
        _ColorChip('Soil Moisture', agriculturalColors.soilMoisture),
        _ColorChip('Temperature', agriculturalColors.temperature),
        _ColorChip('Rainfall', agriculturalColors.rainfall),
      ],
    );
  }

  Widget _buildTypography(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: theme.textTheme.displayLarge),
        Text('Headline Large', style: theme.textTheme.headlineLarge),
        Text('Title Large', style: theme.textTheme.titleLarge),
        Text('Body Large', style: theme.textTheme.bodyLarge),
        Text('Label Large', style: theme.textTheme.labelLarge),
      ],
    );
  }

  Widget _buildComponents(ThemeData theme, AppSpacing spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buttons
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
          ],
        ),
        SizedBox(height: spacing.md),

        // Cards
        Card(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farm Data Card', style: theme.textTheme.titleMedium),
                SizedBox(height: spacing.sm),
                Text(
                  'This is a sample card showing farm information.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),

        // Form Elements
        TextField(
          decoration: InputDecoration(
            labelText: 'Farm Name',
            hintText: 'Enter your farm name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacing.inputRadius),
            ),
          ),
        ),
        SizedBox(height: spacing.sm),

        Row(
          children: [
            Checkbox(value: true, onChanged: (value) {}),
            const Text('Organic Farm'),
            SizedBox(width: spacing.md),
            Switch(value: true, onChanged: (value) {}),
            const Text('Notifications'),
          ],
        ),
      ],
    );
  }

  Widget _buildAgriculturalData(
    ThemeData theme,
    AgriculturalColors agriculturalColors,
  ) {
    return Column(
      children: [
        // Data Cards
        Row(
          children: [
            Expanded(
              child: _DataCard(
                title: 'Soil Moisture',
                value: '65%',
                color: agriculturalColors.soilMoisture,
                icon: Icons.water_drop,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DataCard(
                title: 'Temperature',
                value: '24°C',
                color: agriculturalColors.temperature,
                icon: Icons.thermostat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DataCard(
                title: 'Rainfall',
                value: '12mm',
                color: agriculturalColors.rainfall,
                icon: Icons.cloud,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DataCard(
                title: 'Crop Health',
                value: 'Good',
                color: agriculturalColors.cropHealthGood,
                icon: Icons.eco,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Gradient Examples
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: agriculturalColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Primary Gradient',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = color.computeLuminance() > 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isLight ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _DataCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
