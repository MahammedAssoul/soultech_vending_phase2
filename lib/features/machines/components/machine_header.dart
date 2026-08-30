part of '../machine_details_page.dart';

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.machine});
  final Machine machine;

  @override
  Widget build(BuildContext context) {
    final m = machine;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_shipping,
                color: AppColors.blue, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${m.code} • ${m.location}',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  '${AppLang.tr('commissionPercent')} ${m.commissionPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Chip(
              label: Text(
                  m.active ? AppLang.tr('active') : AppLang.tr('inactive')),
              backgroundColor: m.active
                  ? Colors.green.withValues(alpha: .12)
                  : Colors.grey.shade200,
              labelStyle: TextStyle(
                color: m.active ? Colors.green.shade800 : Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide.none,
            ),
          ]),
        ]),
      ),
    );
  }
}
