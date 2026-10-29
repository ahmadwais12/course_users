import 'package:flutter/material.dart';

class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool horizontalScroll;
  final double? columnWidth;
  final Color? headerColor;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.horizontalScroll = true,
    this.columnWidth,
    this.headerColor,
    this.headerStyle,
    this.cellStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHeaderStyle = headerStyle ?? theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w700,
    );
    final effectiveCellStyle = cellStyle ?? theme.textTheme.bodyMedium!;

    final table = DataTable(
      headingRowColor: WidgetStateProperty.all(
        headerColor ?? theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
      columnSpacing: 16,
      horizontalMargin: 12,
      dataRowMinHeight: 48,
      dataRowMaxHeight: 60,
      columns: columns.map((col) => DataColumn(
        label: Text(col, style: effectiveHeaderStyle),
      )).toList(),
      rows: rows.map((cells) => DataRow(
        cells: cells.map((cell) => DataCell(
          DefaultTextStyle(style: effectiveCellStyle, child: cell),
        )).toList(),
      )).toList(),
    );

    if (horizontalScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      );
    }
    return table;
  }
}
