import 'package:flutter/material.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/features/machines/machine_form_page.dart';
import 'package:soultech_vending/features/machines/machine_details_page.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});
  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  final repo = MachineRepository();
  List<Machine> machines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    machines = await repo.getAll();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _edit([Machine? machine]) async {
    final changed = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => MachineFormPage(machine: machine)));
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Machines'), actions: [
          IconButton(onPressed: () => _edit(), icon: const Icon(Icons.add))
        ]),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(),
            icon: const Icon(Icons.add),
            label: const Text('Add Machine')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: machines.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No machines yet'))
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: machines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final m = machines[i];
                          return Card(
                              child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          color: AppColors.blue
                                              .withValues(alpha: .1),
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: const Icon(Icons.local_shipping,
                                          color: AppColors.blue)),
                                  title: Text(m.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800)),
                                  subtitle: Text(
                                      '${m.code} • ${m.location}\nCommission: ${m.commissionPercent.toStringAsFixed(1)}%'),
                                  isThreeLine: true,
                                  trailing: PopupMenuButton<String>(
                                      onSelected: (v) async {
                                        if (v == 'edit') _edit(m);
                                        if (v == 'delete' && m.id != null) {
                                          await repo.delete(m.id!);
                                          _load();
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                            PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit')),
                                            PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'))
                                          ]),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => MachineDetailsPage(
                                              machine: m)))));
                        },
                      )),
      );
}
