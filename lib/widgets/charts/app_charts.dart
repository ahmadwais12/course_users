import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:course_users/theme.dart';

/// Bar chart showing values per category.
class AppBarChart extends StatelessWidget {
  final String title;
  final List<AppBarChartItem> items;
  final Color accent;

  const AppBarChart({
    super.key,
    required this.title,
    required this.items,
    this.accent = Colors.black87,
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
            Text(title, style: theme.textTheme.titleMedium?.bold),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: items.fold<double>(
                      0, (max, i) => i.value > max ? i.value : max) *
                      1.2,
                  barGroups: items.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value,
                          color: e.value.color ?? accent,
                          width: 18,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= items.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              items[idx].label,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarChartItem {
  final String label;
  final double value;
  final Color? color;
  const AppBarChartItem(this.label, this.value, {this.color});
}

/// Pie chart showing proportional distribution.
class AppPieChart extends StatelessWidget {
  final String title;
  final List<AppPieChartItem> items;

  const AppPieChart({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.bold),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: items.asMap().entries.map((e) {
                    return PieChartSectionData(
                      value: e.value.value,
                      color: e.value.color,
                      title: '${e.value.value.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      radius: 50,
                    );
                  }).toList(),
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.label,
                          style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Text('${item.value.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AppPieChartItem {
  final String label;
  final double value;
  final Color color;
  const AppPieChartItem(this.label, this.value, this.color);
}

/// Line chart for trends over time.
class AppLineChart extends StatelessWidget {
  final String title;
  final List<AppLineChartPoint> points;
  final Color accent;

  const AppLineChart({
    super.key,
    required this.title,
    required this.points,
    this.accent = Colors.black87,
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
            Text(title, style: theme.textTheme.titleMedium?.bold),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: points
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: accent,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: accent,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: accent.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(points[idx].label,
                                style: theme.textTheme.labelSmall),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLineChartPoint {
  final String label;
  final double value;
  const AppLineChartPoint(this.label, this.value);
}

/// Horizontal progress bar widget.
class AppProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  final bool showPercent;

  const AppProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 100,
    this.color = Colors.black87,
    this.showPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const Spacer(),
            if (showPercent)
              Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// A card showing a key metric with an icon.
class AppMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? trend;

  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trend,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const Spacer(),
                if (trend != null)
                  Text(trend!, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
