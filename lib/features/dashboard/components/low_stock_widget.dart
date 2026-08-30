part of '../dashboard_page.dart';

class LowStockWidget extends StatelessWidget {
  final double lowStockCount;
  const LowStockWidget({super.key, required this.lowStockCount});

  @override
  Widget build(BuildContext context) {
    if (lowStockCount == 0) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
        title: Text(AppLang.tr('lowStockProducts')),
        subtitle: Text('${lowStockCount.toInt()}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
