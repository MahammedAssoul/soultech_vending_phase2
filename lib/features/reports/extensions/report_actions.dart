part of '../reports_page.dart';

/// Pure date math for the reports quick filters (no widget state).
extension _ReportRangeHelper on _ReportsPageState {
  void _applyRange(DateTime from, DateTime to) {
    _from = from;
    _to = to;
  }
}
