import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/modern_bottom_navigation.dart';

/// Farmer home shell with bottom navigation
class FarmerHomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const FarmerHomeShell({super.key, required this.navigationShell});

  @override
  State<FarmerHomeShell> createState() => _FarmerHomeShellState();
}

class _FarmerHomeShellState extends State<FarmerHomeShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        items: FarmerNavItems.items,
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
