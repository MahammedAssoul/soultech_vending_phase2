part of '../records_page.dart';

class _RecordFilters extends StatelessWidget {
  const _RecordFilters({
    required this.type,
    required this.machineId,
    required this.machines,
    required this.from,
    required this.to,
    required this.onTypeChanged,
    required this.onMachineChanged,
    required this.onFromChanged,
    required this.onToChanged,
  });

  final String type;
  final int? machineId;
  final List<Machine> machines;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<int?> onMachineChanged;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: AppLang.tr('filter')),
              items: [
                DropdownMenuItem(value: 'all', child: Text(AppLang.tr('all'))),
                ...RecordType.values.map((t) =>
                    DropdownMenuItem(value: t.name, child: Text(t.label))),
              ],
              onChanged: (v) => onTypeChanged(v!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: machineId,
              decoration: InputDecoration(labelText: AppLang.tr('machine')),
              items: [
                DropdownMenuItem<int?>(
                    value: null, child: Text(AppLang.tr('allMachines'))),
                ...machines.map((m) =>
                    DropdownMenuItem<int?>(value: m.id, child: Text(m.name))),
              ],
              onChanged: (v) => onMachineChanged(v),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(
            child: _DateChip(
              label: AppLang.tr('fromDate'),
              date: from,
              onSelected: onFromChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateChip(
              label: AppLang.tr('toDate'),
              date: to,
              onSelected: onToChanged,
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
}
