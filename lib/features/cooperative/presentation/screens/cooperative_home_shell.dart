import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/modern_bottom_navigation.dart';

/// Cooperative home shell with bottom navigation
class CooperativeHomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const CooperativeHomeShell({super.key, required this.navigationShell});

  @override
  State<CooperativeHomeShell> createState() => _CooperativeHomeShellState();
}

class _CooperativeHomeShellState extends State<CooperativeHomeShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        items: CooperativeNavItems.items,
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
