part of '../dashboard_page.dart';

/// Cash collection chart for the dashboard.
class _CollectionChart extends StatelessWidget {
  const _CollectionChart({required this.spots});

  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('collectionsTrend'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.indigo,
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
