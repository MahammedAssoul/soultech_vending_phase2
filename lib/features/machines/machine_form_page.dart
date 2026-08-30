import 'package:flutter/material.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';

class MachineFormPage extends StatefulWidget {
  const MachineFormPage({super.key, this.machine});
  final Machine? machine;
  @override
  State<MachineFormPage> createState() => _MachineFormPageState();
}

class _MachineFormPageState extends State<MachineFormPage> {
  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.machine?.name ?? '');
  late final code = TextEditingController(text: widget.machine?.code ?? '');
  late final location =
      TextEditingController(text: widget.machine?.location ?? '');
  late final commission = TextEditingController(
      text: widget.machine?.commissionPercent.toString() ?? '0');
  bool active = true;

  @override
  void initState() {
    super.initState();
    active = widget.machine?.active ?? true;
  }

  @override
  void dispose() {
    name.dispose();
    code.dispose();
    location.dispose();
    commission.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final machine = Machine(
        id: widget.machine?.id,
        name: name.text.trim(),
        code: code.text.trim(),
        location: location.text.trim(),
        commissionPercent: double.tryParse(commission.text) ?? 0,
        active: active,
        installedAt: widget.machine?.installedAt ?? DateTime.now());
    await MachineRepository().save(machine);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(widget.machine == null ? 'Add Machine' : 'Edit Machine')),
      body: Form(
          key: formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Machine name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            TextFormField(
                controller: code,
                decoration: const InputDecoration(labelText: 'Machine code'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            TextFormField(
                controller: location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            TextFormField(
                controller: commission,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Location commission %', suffixText: '%')),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: active,
                onChanged: (v) => setState(() => active = v),
                title: const Text('Active machine')),
            const SizedBox(height: 20),
            FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Machine'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52))),
          ])));
}
