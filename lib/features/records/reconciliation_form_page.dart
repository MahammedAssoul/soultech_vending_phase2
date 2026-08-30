import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/record_form_scaffold.dart';
import 'package:soultech_vending/data/models/reconciliation_record.dart';
import 'package:soultech_vending/data/repositories/reconciliation_repository.dart';

class ReconciliationFormPage extends StatefulWidget {
  const ReconciliationFormPage(
      {super.key, this.record, this.preselectedMachineId});
  final ReconciliationRecord? record;
  final int? preselectedMachineId;

  @override
  State<ReconciliationFormPage> createState() => _ReconciliationFormPageState();
}

class _ReconciliationFormPageState extends State<ReconciliationFormPage> {
  final _expectedCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  double get _expected => double.tryParse(_expectedCtrl.text) ?? 0;
  double get _actual => double.tryParse(_actualCtrl.text) ?? 0;
  double get _difference => _actual - _expected;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _expectedCtrl.text = widget.record!.expectedAmount.toString();
      _actualCtrl.text = widget.record!.actualAmount.toString();
      _notesCtrl.text = widget.record!.notes;
      _date = widget.record!.date;
    }
    _expectedCtrl.addListener(() => setState(() {}));
    _actualCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _expectedCtrl.dispose();
    _actualCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(int? machineId) async {
    if (machineId == null) return;
    final record = ReconciliationRecord(
      id: widget.record?.id,
      machineId: machineId,
      expectedAmount: _expected,
      actualAmount: _actual,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    await ReconciliationRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _expectedField() => TextFormField(
        controller: _expectedCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
            labelText: '${AppLang.tr('expected')} *',
            prefixText: '${AppLang.tr('currency')} '),
        validator: (v) {
          final n = double.tryParse(v ?? '');
          if (n == null || n < 0) return AppLang.tr('mustBeNonNegative');
          return null;
        },
      );

  Widget _actualField() => TextFormField(
        controller: _actualCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
            labelText: '${AppLang.tr('actual')} *',
            prefixText: '${AppLang.tr('currency')} '),
        validator: (v) {
          final n = double.tryParse(v ?? '');
          if (n == null || n < 0) return AppLang.tr('mustBeNonNegative');
          return null;
        },
      );

  Widget _differenceCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              _difference == 0 ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _difference == 0
                  ? Colors.green.shade100
                  : Colors.orange.shade100),
        ),
        child: Row(children: [
          Text(AppLang.tr('difference'),
              style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(
            Fmt.money(_difference),
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _difference == 0
                    ? Colors.green
                    : (_difference > 0 ? Colors.green : Colors.red)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
        isEditing: widget.record != null,
        addTitle: AppLang.tr('addReconciliation'),
        editTitle: AppLang.tr('editReconciliation'),
        machineId: widget.preselectedMachineId ?? widget.record?.machineId,
        onMachineChanged: (_) {},
        date: _date,
        onDateChanged: (d) => setState(() => _date = d),
        notesController: _notesCtrl,
        onSave: _save,
        children: [
          _expectedField(),
          const SizedBox(height: 14),
          _actualField(),
          const SizedBox(height: 14),
          _differenceCard(),
        ],
      );
}
