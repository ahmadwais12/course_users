import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:course_users/screens/ads/ads_pages.dart';
import 'package:course_users/screens/dashboard_screen.dart';
import 'package:course_users/screens/payments_screen.dart';
import 'package:course_users/screens/programs_screen.dart';
import 'package:course_users/screens/students_screen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late AnimationController _animController;

  late final List<Widget> _pages = const [
    DashboardScreen(),
    StudentsScreen(),
    ProgramsScreen(),
    PaymentsScreen(),
    AdsHubScreen(),
  ];

  static const _items = [
    _NavItem('Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Students', Icons.groups_rounded, Icons.groups_outlined),
    _NavItem('Programs', Icons.menu_book_rounded, Icons.menu_book_outlined),
    _NavItem('Payments', Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined),
    _NavItem('Ads', Icons.campaign_rounded, Icons.campaign_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _animController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _CurvedNavBar(
          selectedIndex: _index,
          items: _items,
          primary: primary,
          surface: surface,
          animController: _animController,
          onTap: _onTap,
        ),
      ),
    );
  }
}

// ─── Curved Nav Bar ──────────────────────────────────────────────────────────

class _CurvedNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final Color primary;
  final Color surface;
  final AnimationController animController;
  final ValueChanged<int> onTap;

  const _CurvedNavBar({
    required this.selectedIndex,
    required this.items,
    required this.primary,
    required this.surface,
    required this.animController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const barHeight = 72.0;
    const notchRadius = 30.0;
    final totalItems = items.length;
    final itemWidth =
        (MediaQuery.of(context).size.width) / totalItems;
    final notchCenterX = itemWidth * selectedIndex + itemWidth / 2;

    return SizedBox(
      height: barHeight + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Painted curved bar
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvedBarPainter(
                notchCenterX: notchCenterX,
                notchRadius: notchRadius,
                color: surface,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                borderColor:
                    theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          // Nav items
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barHeight,
            child: Row(
              children: List.generate(totalItems, (i) {
                final selected = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected ? 0.0 : 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Icon(
                            items[i].icon,
                            size: 22,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Floating active bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: notchCenterX - notchRadius,
            top: -(notchRadius * 0.55),
            child: GestureDetector(
              onTap: () => onTap(selectedIndex),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animController,
                  curve: Curves.easeOutBack,
                ),
                child: Container(
                  width: notchRadius * 2,
                  height: notchRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[selectedIndex].selectedIcon,
                        color: theme.colorScheme.onSurface,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Active label below bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: notchCenterX - 40,
            top: notchRadius + 10,
            child: SizedBox(
              width: 80,
              child: FadeTransition(
                opacity: animController,
                child: Text(
                  items[selectedIndex].label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CustomPainter for the curved notch bar ───────────────────────────────────

class _CurvedBarPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final Color color;
  final Color shadowColor;
  final Color borderColor;

  _CurvedBarPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.color,
    required this.shadowColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = _buildPath(size);

    // Shadow
    canvas.drawPath(path, shadowPaint);
    // Fill
    canvas.drawPath(path, paint);
    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  Path _buildPath(Size size) {
    const cornerRadius = 28.0;
    final notchDepth = notchRadius * 0.72;
    final curveWidth = notchRadius * 1.6;

    final path = Path();
    path.moveTo(cornerRadius, 0);

    // Top-left to notch start
    final notchLeft = notchCenterX - curveWidth;
    final notchRight = notchCenterX + curveWidth;

    path.lineTo(math.max(notchLeft, cornerRadius), 0);

    if (notchLeft > cornerRadius) {
      // Smooth curve down into notch
      path.cubicTo(
        notchCenterX - curveWidth * 0.55,
        0,
        notchCenterX - notchRadius * 0.9,
        notchDepth,
        notchCenterX,
        notchDepth,
      );
      path.cubicTo(
        notchCenterX + notchRadius * 0.9,
        notchDepth,
        notchCenterX + curveWidth * 0.55,
        0,
        notchRight,
        0,
      );
    }

    // Top-right to bottom-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_CurvedBarPainter old) =>
      old.notchCenterX != notchCenterX ||
      old.color != color ||
      old.borderColor != borderColor;
}

// ─── Nav Item model ───────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData selectedIcon;
  final IconData icon;

  const _NavItem(this.label, this.selectedIcon, this.icon);
}
