import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';

enum RecordType {
  sale,
  restocking,
  changeAdded,
  cashReading,
  reconciliation,
  cashCollection,
}

/// Display order for the "Add Record" sheet. Cash Collection is first because
/// it is the main daily operation.
const _displayOrder = <RecordType>[
  RecordType.cashCollection,
  RecordType.sale,
  RecordType.restocking,
  RecordType.changeAdded,
  RecordType.cashReading,
  RecordType.reconciliation,
];

extension RecordTypeExt on RecordType {
  String get label {
    switch (this) {
      case RecordType.sale:
        return AppLang.tr('sales');
      case RecordType.restocking:
        return AppLang.tr('restocking');
      case RecordType.changeAdded:
        return AppLang.tr('changeAdded');
      case RecordType.cashReading:
        return AppLang.tr('cashReading');
      case RecordType.reconciliation:
        return AppLang.tr('reconciliation');
      case RecordType.cashCollection:
        return AppLang.tr('cashCollection');
    }
  }

  String get labelAr {
    switch (this) {
      case RecordType.sale:
        return 'المبيعات';
      case RecordType.restocking:
        return 'إعادة تعبئة المخزون';
      case RecordType.changeAdded:
        return 'إضافة فكة';
      case RecordType.cashReading:
        return 'قراءة النقدية';
      case RecordType.reconciliation:
        return 'التسوية';
      case RecordType.cashCollection:
        return 'تحصيل النقدية';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.sale:
        return Icons.point_of_sale;
      case RecordType.restocking:
        return Icons.inventory_2_outlined;
      case RecordType.changeAdded:
        return Icons.savings_outlined;
      case RecordType.cashReading:
        return Icons.local_atm_outlined;
      case RecordType.reconciliation:
        return Icons.balance_outlined;
      case RecordType.cashCollection:
        return Icons.payments_outlined;
    }
  }

  Color get color {
    switch (this) {
      case RecordType.sale:
        return AppColors.blue;
      case RecordType.restocking:
        return Colors.green;
      case RecordType.changeAdded:
        return Colors.orange;
      case RecordType.cashReading:
        return Colors.purple;
      case RecordType.reconciliation:
        return Colors.teal;
      case RecordType.cashCollection:
        return Colors.indigo;
    }
  }
}

/// Shows a bottom sheet for selecting a record type
Future<RecordType?> showRecordTypeSelector(BuildContext context) {
  return showModalBottomSheet<RecordType>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title row with close button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLang.tr('addRecord'),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(AppLang.tr('selectRecordType'),
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                  tooltip: AppLang.tr('close'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Scrollable options list
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Cash Collection first — the main daily option.
                    ..._displayOrder.map((type) => _RecordTypeOption(
                          type: type,
                          onTap: () => Navigator.pop(ctx, type),
                        )),
                    // Extra padding at the bottom for comfortable scrolling
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RecordTypeOption extends StatelessWidget {
  const _RecordTypeOption({required this.type, required this.onTap});
  final RecordType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: type.color.withValues(alpha: .2)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(type.icon, color: type.color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(type.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text(type.labelAr,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ]),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ]),
          ),
        ),
      );
}
