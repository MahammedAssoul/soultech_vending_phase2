import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';

/// Shared scaffolding for the operational record forms.
///
/// Encapsulates: machine dropdown (with preselection), date picker field,
/// notes field, localised add/edit AppBar title and the Save button — the
/// parts all four record forms have in common.
class RecordFormScaffold extends StatefulWidget {
  const RecordFormScaffold({
    super.key,
    required this.isEditing,
    required this.addTitle,
    required this.editTitle,
    required this.machineId,
    required this.onMachineChanged,
    required this.date,
    required this.onDateChanged,
    required this.notesController,
    required this.onSave,
    this.children = const [],
    this.machineRequired = true,
  });

  final bool isEditing;
  final String addTitle;
  final String editTitle;
  final int? machineId;
  final ValueChanged<int?> onMachineChanged;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController notesController;

  /// Called when the form is valid; receives the selected machine id.
  final void Function(int? machineId) onSave;
  final List<Widget> children;
  final bool machineRequired;

  @override
  State<RecordFormScaffold> createState() => _RecordFormScaffoldState();
}

class _RecordFormScaffoldState extends State<RecordFormScaffold> {
  final _formKey = GlobalKey<FormState>();
  List<Machine> _machines = [];
  Machine? _selectedMachine;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _machines = await MachineRepository().getAll();
    if (!mounted) return;
    setState(() {
      _selectedMachine = _machines.isEmpty
          ? null
          : _machines.firstWhere(
              (m) => m.id == widget.machineId,
              orElse: () => _machines.first,
            );
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) widget.onDateChanged(d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.machineRequired && _selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLang.tr('pleaseSelectMachine'))));
      return;
    }
    widget.onSave(_selectedMachine?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? widget.editTitle : widget.addTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (widget.machineRequired) ...[
                    DropdownButtonFormField<Machine>(
                      initialValue: _selectedMachine,
                      decoration:
                          InputDecoration(labelText: AppLang.tr('machine')),
                      items: _machines
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m.name)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedMachine = v);
                        widget.onMachineChanged(v?.id);
                      },
                      validator: (v) =>
                          v == null ? AppLang.tr('required') : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  ...widget.children,
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration:
                          InputDecoration(labelText: AppLang.tr('date')),
                      child: Text(DateFormat('dd/MM/yyyy').format(widget.date)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: widget.notesController,
                    decoration: InputDecoration(labelText: AppLang.tr('notes')),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(AppLang.tr('save')),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                  ),
                ],
              ),
            ),
    );
  }
}
