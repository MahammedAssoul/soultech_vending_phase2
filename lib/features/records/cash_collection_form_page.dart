import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/widgets/record_form_scaffold.dart';
import 'package:soultech_vending/data/models/cash_collection_record.dart';
import 'package:soultech_vending/data/repositories/cash_collection_repository.dart';

class CashCollectionFormPage extends StatefulWidget {
  const CashCollectionFormPage(
      {super.key, this.record, this.preselectedMachineId});
  final CashCollectionRecord? record;
  final int? preselectedMachineId;

  @override
  State<CashCollectionFormPage> createState() => _CashCollectionFormPageState();
}

class _CashCollectionFormPageState extends State<CashCollectionFormPage> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _amountCtrl.text = widget.record!.collectedAmount.toString();
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
    final record = CashCollectionRecord(
      id: widget.record?.id,
      machineId: machineId,
      collectedAmount: double.tryParse(_amountCtrl.text) ?? 0,
      date: _date,
      notes: _notesCtrl.text.trim(),
    );
    await CashCollectionRepository().save(record);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _amountField() => TextFormField(
        controller: _amountCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: '${AppLang.tr('collectedAmount')} *',
          prefixText: '${AppLang.tr('currency')} ',
          helperText: AppLang.tr('collectedAmountHint'),
        ),
        validator: (v) {
          final n = double.tryParse(v ?? '');
          if (n == null || n < 0) return AppLang.tr('mustBeNonNegative');
          return null;
        },
      );

  @override
  Widget build(BuildContext context) => RecordFormScaffold(
        isEditing: widget.record != null,
        addTitle: AppLang.tr('addCashCollection'),
        editTitle: AppLang.tr('editCashCollection'),
        machineId: widget.preselectedMachineId ?? widget.record?.machineId,
        onMachineChanged: (_) {},
        date: _date,
        onDateChanged: (d) => setState(() => _date = d),
        notesController: _notesCtrl,
        onSave: _save,
        children: [
          _amountField(),
          const SizedBox(height: 14),
          // Collection summary hint
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Row(children: [
              const Icon(Icons.handshake_outlined, color: Colors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLang.tr('cashCollectionInfo'),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ]),
          ),
        ],
      );
}
