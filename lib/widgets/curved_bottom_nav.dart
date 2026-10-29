import 'package:flutter/material.dart';

class CurvedBottomNav extends StatelessWidget {
  final List<CurvedBottomNavItem> items;
  final Function(int) onTap;
  final int currentIndex;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;

  const CurvedBottomNav({
    super.key,
    required this.items,
    required this.onTap,
    required this.currentIndex,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surface;
    final selected = selectedColor ?? theme.colorScheme.primary;
    final unselected =
        unselectedColor ?? theme.colorScheme.outline.withValues(alpha: 0.5);
    final hasCenterButton = items.length.isOdd;

    return CustomPaint(
      painter: CurvedNavPainter(
        color: bg,
        showCenterCutout: hasCenterButton,
      ),
      child: SizedBox(
        height: hasCenterButton ? height + 10 : height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Navigation items
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: hasCenterButton ? 0 : 8,
                  bottom: hasCenterButton ? 20 : 8,
                ),
                child: Row(
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == currentIndex;
                    final isCenter =
                        hasCenterButton && index == items.length ~/ 2;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isCenter
                                    ? Colors.white
                                    : (isSelected ? selected : unselected),
                                size: isCenter ? 28 : (isSelected ? 26 : 22),
                              ),
                            ),
                            if (!isCenter) ...[
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected ? selected : unselected,
                                    fontSize: isSelected ? 12 : 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Center floating button
            if (hasCenterButton)
              Positioned(
                top: 0,
                child: InkWell(
                  onTap: () => onTap(items.length ~/ 2),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          selected,
                          selected.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selected.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      items[items.length ~/ 2].selectedIcon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CurvedBottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const CurvedBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class CurvedNavPainter extends CustomPainter {
  final Color color;
  final bool showCenterCutout;

  CurvedNavPainter({
    required this.color,
    this.showCenterCutout = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (!showCenterCutout) {
      // Simple rectangle without cutout
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final path = Path();
    final centerX = size.width / 2;
    final curveWidth = 80.0;
    final curveDepth = 35.0;
    final top = 0.0;

    path.moveTo(0, top);
    path.lineTo(centerX - curveWidth, top);

    // Left curve
    path.quadraticBezierTo(
      centerX - curveWidth / 2,
      curveDepth,
      centerX,
      curveDepth,
    );

    // Right curve
    path.quadraticBezierTo(
      centerX + curveWidth / 2,
      curveDepth,
      centerX + curveWidth,
      top,
    );

    path.lineTo(size.width, top);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
