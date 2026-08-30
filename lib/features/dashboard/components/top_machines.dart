part of '../dashboard_page.dart';

class _TopMachinesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topMachines;
  const _TopMachinesWidget({required this.topMachines});

  @override
  Widget build(BuildContext context) {
    if (topMachines.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('topMachines'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final m in topMachines)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping,
                      size: 20, color: AppColors.blue),
                ),
                title: Text('${m['machine_name']}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${m['location']}'),
                trailing: Text(
                  Fmt.money((m['total_sales'] as num?)?.toDouble() ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
