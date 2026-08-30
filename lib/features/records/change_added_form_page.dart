import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/widgets/record_form_scaffold.dart';
import 'package:soultech_vending/data/models/change_added_record.dart';
import 'package:soultech_vending/data/repositories/change_added_repository.dart';

class ChangeAddedFormPage extends StatefulWidget {
  const ChangeAddedFormPage(
      {super.key, this.record, this.preselectedMachineId});
  final ChangeAddedRecord? record;
  final int? preselectedMachineId;

  @override
  State<ChangeAddedFormPage> createState() => _ChangeAddedFormPageState();
}

class _ChangeAddedFormPageState extends State<ChangeAddedFormPage> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _amountCtrl.text = widget.record!.amount.toString();
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
    final record = ChangeAddedRecord(
      id: widget.record?.id,
      machineId: machineId,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    await ChangeAddedRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _amountField() => TextFormField(
        controller: _amountCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
            labelText: '${AppLang.tr('amount')} *',
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
        addTitle: AppLang.tr('addChangeAdded'),
        editTitle: AppLang.tr('editChangeAdded'),
        machineId: widget.preselectedMachineId ?? widget.record?.machineId,
        onMachineChanged: (_) {},
        date: _date,
        onDateChanged: (d) => setState(() => _date = d),
        notesController: _notesCtrl,
        onSave: _save,
        children: [_amountField()],
      );
}
