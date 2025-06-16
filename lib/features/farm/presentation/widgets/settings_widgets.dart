import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/farm_settings.dart';

/// Settings category card widget
class SettingsCategoryCard extends StatelessWidget {
  final SettingsCategory category;
  final VoidCallback onTap;

  const SettingsCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.spacing16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: ResponsiveUtils.iconSize24,
                ),
              ),
              SizedBox(width: ResponsiveUtils.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.height4),
                    Text(
                      category.description,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: ResponsiveUtils.iconSize20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.general:
        return Icons.settings;
      case SettingsCategory.notifications:
        return Icons.notifications;
      case SettingsCategory.activities:
        return Icons.task_alt;
      case SettingsCategory.weather:
        return Icons.wb_sunny;
      case SettingsCategory.security:
        return Icons.security;
      case SettingsCategory.backup:
        return Icons.backup;
      case SettingsCategory.about:
        return Icons.info;
    }
  }

  Color _getCategoryColor(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.general:
        return Colors.blue;
      case SettingsCategory.notifications:
        return Colors.orange;
      case SettingsCategory.activities:
        return Colors.green;
      case SettingsCategory.weather:
        return Colors.amber;
      case SettingsCategory.security:
        return Colors.red;
      case SettingsCategory.backup:
        return Colors.purple;
      case SettingsCategory.about:
        return Colors.grey;
    }
  }
}

/// Settings toggle item widget
class SettingsToggleItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? iconColor;

  const SettingsToggleItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize24,
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing16,
        vertical: ResponsiveUtils.spacing4,
      ),
    );
  }
}

/// Settings selection item widget
class SettingsSelectionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final Color? iconColor;

  const SettingsSelectionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: ResponsiveUtils.iconSize24,
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing8),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: ResponsiveUtils.iconSize20,
          ),
        ],
      ),
      onTap: () => _showSelectionDialog(context, title, value, options, onChanged),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing16,
        vertical: ResponsiveUtils.spacing4,
      ),
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.fontSize14,
                ),
              ),
              value: option,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Settings slider item widget
class SettingsSliderItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;
  final IconData? icon;
  final Color? iconColor;

  const SettingsSliderItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.valueFormatter,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: icon != null
              ? Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                  size: ResponsiveUtils.iconSize24,
                )
              : null,
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              : null,
          trailing: Text(
            valueFormatter?.call(value) ?? value.toStringAsFixed(0),
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing16,
            vertical: ResponsiveUtils.spacing4,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.spacing16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Settings action item widget
class SettingsActionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool isDestructive;

  const SettingsActionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? 
        (isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface);
    final effectiveIconColor = iconColor ?? 
        (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary);
    
    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: effectiveIconColor,
              size: ResponsiveUtils.iconSize24,
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: ResponsiveUtils.fontSize14,
          fontWeight: FontWeight.w500,
          color: effectiveTextColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        size: ResponsiveUtils.iconSize20,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacing16,
        vertical: ResponsiveUtils.spacing4,
      ),
    );
  }
}
