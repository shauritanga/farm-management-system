import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../utils/responsive_utils.dart';

/// Modern bottom navigation bar with sleek design
class ModernBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<ModernNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final activeCol = activeColor ?? theme.colorScheme.primary;
    final inactiveCol =
        inactiveColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, -ResponsiveUtils.spacing2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: ResponsiveUtils.bottomNavHeight,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing20,
            vertical: ResponsiveUtils.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = currentIndex == index;

                  return _buildNavItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onTap(index),
                    activeColor: activeCol,
                    inactiveColor: inactiveCol,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required ModernNavItem item,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal:
              isSelected
                  ? ResponsiveUtils.spacing16
                  : ResponsiveUtils.spacing12,
          vertical: ResponsiveUtils.spacing8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: ResponsiveUtils.iconSize24,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            if (isSelected && item.label != null) ...[
              SizedBox(width: ResponsiveUtils.spacing8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  item.label!,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Navigation item model
class ModernNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String? label;

  const ModernNavItem({
    required this.icon,
    required this.activeIcon,
    this.label,
  });
}

/// Predefined navigation items for farmer
class FarmerNavItems {
  static List<ModernNavItem> get items => [
    const ModernNavItem(
      icon: HugeIcons.strokeRoundedHome11,
      activeIcon: HugeIcons.strokeRoundedHome11,
      label: 'Home',
    ),
    const ModernNavItem(
      icon: HugeIcons.strokeRoundedLeaf01,
      activeIcon: HugeIcons.strokeRoundedLeaf01,
      label: 'Farms',
    ),
    const ModernNavItem(
      icon: HugeIcons.strokeRoundedShoppingBasket01,
      activeIcon: HugeIcons.strokeRoundedShoppingBasket01,
      label: 'Marketplace',
    ),
    const ModernNavItem(
      icon: HugeIcons.strokeRoundedUser03,
      activeIcon: HugeIcons.strokeRoundedUser03,
      label: 'Profile',
    ),
  ];
}

/// Predefined navigation items for cooperative
class CooperativeNavItems {
  static List<ModernNavItem> get items => [
    const ModernNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const ModernNavItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      label: 'Farmers',
    ),
    const ModernNavItem(
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale,
      label: 'Sales',
    ),
    const ModernNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Reports',
    ),
    const ModernNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];
}
