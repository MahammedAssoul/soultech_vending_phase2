import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/core/utils/format.dart';
import 'package:soultech_vending/core/widgets/empty_state.dart';
import 'package:soultech_vending/core/widgets/report_widgets.dart';
import 'package:soultech_vending/data/models/machine.dart';
import 'package:soultech_vending/data/repositories/machine_repository.dart';
import 'package:soultech_vending/features/reports/excel_report_service.dart';
import 'package:soultech_vending/features/reports/pdf_report_service.dart';
import 'package:soultech_vending/features/reports/report_service.dart';

part 'components/report_filters.dart';
part 'components/report_performance.dart';
part 'components/report_sections.dart';
part 'components/report_summary.dart';
part 'extensions/report_actions.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _reportService = ReportService();

  List<Machine> _machines = [];
  int? _machineId;
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  bool _loading = true;
  String? _error;
  ReportData? _data;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _machines = await MachineRepository().getAll();
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _reportService.load(
        machineId: _machineId,
        from: _from,
        to: _to,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _exportPdf() async {
    final title = AppLang.tr('reports');
    try {
      await PdfReportService.export(_data!, title: title);
      if (!mounted) return;
      _showSnack(AppLang.tr('exportSuccess'));
    } catch (e) {
      _showSnack('${AppLang.tr('exportFail')}: $e');
    }
  }

  Future<void> _exportExcel() async {
    if (_data == null) return;
    try {
      final bytes = await ExcelReportService.generate(_data!);
      await ExcelReportService.saveAndOpen(bytes);
      if (!mounted) return;
      _showSnack(AppLang.tr('exportSuccess'));
    } catch (e) {
      _showSnack('${AppLang.tr('exportFail')}: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: _to,
    );
    if (d != null) {
      setState(() => _from = d);
      _load();
    }
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) {
      setState(() => _to = d);
      _load();
    }
  }

  void _quickSelect(String which) {
    final now = DateTime.now();
    switch (which) {
      case 'today':
        _applyRange(now, now);
      case 'week':
        _applyRange(now.subtract(const Duration(days: 6)), now);
      case 'month':
        _applyRange(DateTime(now.year, now.month, 1), now);
      case 'lastMonth':
        _applyRange(DateTime(now.year, now.month - 1, 1),
            DateTime(now.year, now.month, 0));
      case 'year':
        _applyRange(DateTime(now.year, 1, 1), now);
    }
    setState(() {});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.tr('reports')),
        actions: [
          IconButton(
            onPressed: _data == null ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: AppLang.tr('exportPdf'),
          ),
          IconButton(
            onPressed: _data == null ? null : _exportExcel,
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: AppLang.tr('exportExcel'),
          ),
        ],
      ),
      body: _buildBody(wide),
    );
  }

  Widget _buildBody(bool wide) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: AppLang.tr('error'),
        message: _error,
      );
    }
    final data = _data!;
    final isEmpty = data.transactions == 0 &&
        data.totalSales == 0 &&
        data.totalSpending == 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ReportFilters(
          machineId: _machineId,
          machines: _machines,
          from: _from,
          to: _to,
          onMachineChanged: (v) {
            setState(() => _machineId = v);
            _load();
          },
          onFrom: _pickFrom,
          onTo: _pickTo,
          onQuick: _quickSelect,
        ),
        const SizedBox(height: 16),
        if (isEmpty)
          EmptyState(
            icon: Icons.inbox_outlined,
            title: AppLang.tr('noData'),
          )
        else ...[
          _ReportSummaryGrid(data: data, wide: wide),
          const SizedBox(height: 16),
          _SalesTrendChart(data: data),
          const SizedBox(height: 16),
          _MachinePerformanceCard(data: data),
          const SizedBox(height: 16),
          _ProductPerformanceCard(data: data),
          const SizedBox(height: 16),
          _CollectionReportCard(data: data),
          const SizedBox(height: 16),
          _SpendingCard(data: data),
          const SizedBox(height: 16),
          _RestockingCard(data: data),
          const SizedBox(height: 16),
          _CashReportCard(data: data),
          const SizedBox(height: 16),
          _ProfitCard(data: data),
        ],
      ],
    );
  }
}
