part of '../reports_page.dart';

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.machineId,
    required this.machines,
    required this.from,
    required this.to,
    required this.onMachineChanged,
    required this.onFrom,
    required this.onTo,
    required this.onQuick,
  });

  final int? machineId;
  final List<Machine> machines;
  final DateTime from;
  final DateTime to;
  final ValueChanged<int?> onMachineChanged;
  final VoidCallback onFrom;
  final VoidCallback onTo;
  final ValueChanged<String> onQuick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLang.tr('reportFilters'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButton<int?>(
                  value: machineId,
                  isExpanded: true,
                  hint: Text(AppLang.tr('allMachines')),
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    DropdownMenuItem<int?>(
                        value: null, child: Text(AppLang.tr('allMachines'))),
                    ...machines.map((m) => DropdownMenuItem<int?>(
                        value: m.id, child: Text(m.name))),
                  ],
                  onChanged: onMachineChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateChip(
                  label: AppLang.tr('fromDate'),
                  date: from,
                  onSelected: (_) => onFrom(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateChip(
                  label: AppLang.tr('toDate'),
                  date: to,
                  onSelected: (_) => onTo(),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Quick filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                QuickFilterChip(
                    label: AppLang.tr('today'), onTap: () => onQuick('today')),
                const SizedBox(width: 8),
                QuickFilterChip(
                    label: AppLang.tr('thisWeek'),
                    onTap: () => onQuick('week')),
                const SizedBox(width: 8),
                QuickFilterChip(
                    label: AppLang.tr('thisMonth'),
                    onTap: () => onQuick('month')),
                const SizedBox(width: 8),
                QuickFilterChip(
                    label: AppLang.tr('lastMonth'),
                    onTap: () => onQuick('lastMonth')),
                const SizedBox(width: 8),
                QuickFilterChip(
                    label: AppLang.tr('thisYear'),
                    onTap: () => onQuick('year')),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
