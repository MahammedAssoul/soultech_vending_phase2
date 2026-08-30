import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A labelled value used in the dashboard and reports (e.g. Total Sales).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(title, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ])),
            ])),
      );
}

/// A small clickable date-range chip used in the Reports filters.
class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.label,
    required this.date,
    required this.onSelected,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        ).then((d) {
          if (d != null) onSelected(d);
        }),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            date == null ? '—' : DateFormat('dd/MM/yyyy').format(date!),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
}

/// Quick filter chip (This Week, Last Month, …).
class QuickFilterChip extends StatelessWidget {
  const QuickFilterChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        onPressed: onTap,
        avatar: const Icon(Icons.bolt, size: 18),
        label: Text(label),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
      );
}

/// Line chart card used for sales/profit charts.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.spots,
    required this.color,
    this.title = '',
  });

  final List<FlSpot> spots;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: color,
                        dotData: const FlDotData(show: false),
                        spots: spots,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
