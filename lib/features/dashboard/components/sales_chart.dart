part of '../dashboard_page.dart';

class _SalesChart extends StatelessWidget {
  const _SalesChart({
    required this.spots,
    required this.range,
    required this.onRangeChanged,
  });

  final List<FlSpot> spots;
  final int range;
  final ValueChanged<int> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(AppLang.tr('last7Days'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7')),
                  ButtonSegment(value: 30, label: Text('30')),
                ],
                selected: {range},
                onSelectionChanged: (s) => onRangeChanged(s.first),
              ),
            ]),
            const SizedBox(height: 18),
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
                      barWidth: 4,
                      color: AppColors.blue,
                      dotData: const FlDotData(show: false),
                      spots: spots.isEmpty
                          ? const [FlSpot(0, 0), FlSpot(1, 0)]
                          : spots,
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
}
