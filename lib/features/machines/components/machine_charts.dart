part of '../machine_details_page.dart';

class _MachineCharts extends StatelessWidget {
  const _MachineCharts({
    required this.salesSpots,
    required this.profitSpots,
    required this.collectionSpots,
    required this.monthCollected,
  });

  final List<FlSpot> salesSpots;
  final List<FlSpot> profitSpots;
  final List<FlSpot> collectionSpots;
  final double monthCollected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('salesTrend'),
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      color: AppColors.blue,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      spots: salesSpots.isEmpty
                          ? const [FlSpot(0, 0), FlSpot(1, 0)]
                          : salesSpots,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppLang.tr('profitTrend'),
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.green,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      spots: profitSpots.isEmpty
                          ? const [FlSpot(0, 0), FlSpot(1, 0)]
                          : profitSpots,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Text(AppLang.tr('collectionsTrend'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              const Spacer(),
              Text(Fmt.money(monthCollected),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.indigo)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.indigo,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      spots: collectionSpots.isEmpty
                          ? const [FlSpot(0, 0), FlSpot(1, 0)]
                          : collectionSpots,
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
