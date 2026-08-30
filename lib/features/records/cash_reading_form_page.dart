import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/widgets/record_form_scaffold.dart';
import 'package:soultech_vending/data/models/cash_reading_record.dart';
import 'package:soultech_vending/data/repositories/cash_reading_repository.dart';

class CashReadingFormPage extends StatefulWidget {
  const CashReadingFormPage(
      {super.key, this.record, this.preselectedMachineId});
  final CashReadingRecord? record;
  final int? preselectedMachineId;

  @override
  State<CashReadingFormPage> createState() => _CashReadingFormPageState();
}

class _CashReadingFormPageState extends State<CashReadingFormPage> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _amountCtrl.text = widget.record!.readingAmount.toString();
      _notesCtrl.text = widget.record!.notes;
      _date = widget.record!.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(int? machineId) async {
    if (machineId == null) return;
    final record = CashReadingRecord(
      id: widget.record?.id,
      machineId: machineId,
      readingAmount: double.tryParse(_amountCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    await CashReadingRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _amountField() => TextFormField(
        controller: _amountCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
            labelText: '${AppLang.tr('readingAmount')} *',
            prefixText: '${AppLang.tr('currency')} '),
        validator: (v) {
          final n = double.tryParse(v ?? '');
          if (n == null || n < 0) return AppLang.tr('mustBeNonNegative');
          return null;
        },
      );

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
        isEditing: widget.record != null,
        addTitle: AppLang.tr('addCashReading'),
        editTitle: AppLang.tr('editCashReading'),
        machineId: widget.preselectedMachineId ?? widget.record?.machineId,
        onMachineChanged: (_) {},
        date: _date,
        onDateChanged: (d) => setState(() => _date = d),
        notesController: _notesCtrl,
        onSave: _save,
        children: [_amountField()],
      );
}
