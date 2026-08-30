import 'package:flutter/material.dart';

/// Bilingual string catalog for Soultech Vending.
///
/// Uses the existing map-based pattern from Phase 1 ([AppStrings.en] /
/// [AppStrings.ar]) extended with a [tr] helper and a [L] key namespace so the
/// whole app can be localized in English and Arabic with RTL support.
class AppLang {
  const AppLang._();

  /// Currently active language ('en' or 'ar').
  static String current = 'en';

  static bool get isAr => current == 'ar';
  static Locale get locale => Locale(current);

  /// Returns the localized value for [key] (English if language is English).
  static String tr(String key) =>
      isAr ? (AppStrings.ar[key] ?? key) : (AppStrings.en[key] ?? key);

  /// Convenience localization of an inline (en, ar) pair.
  static String tr2(String en, String ar) => isAr ? ar : en;
}

/// Convenience helper for inline (en, ar) pairs.
String tr(String en, String ar) => AppLang.tr2(en, ar);

/// Namespace of string keys used across the app.
class L {
  const L._();

  // Navigation
  static const dashboard = 'dashboard';
  static const machines = 'machines';
  static const records = 'records';
  static const inventory = 'inventory';
  static const reports = 'reports';
  static const settings = 'settings';

  // Record types
  static const sales = 'sales';
  static const restocking = 'restocking';
  static const changeAdded = 'changeAdded';
  static const cashReading = 'cashReading';
  static const reconciliation = 'reconciliation';
  static const cashCollection = 'cashCollection';
  static const profit = 'profit';
  static const commission = 'commission';

  // Common
  static const add = 'add';
  static const addRecord = 'addRecord';
  static const edit = 'edit';
  static const delete = 'delete';
  static const save = 'save';
  static const cancel = 'cancel';
  static const close = 'close';
  static const search = 'search';
  static const filter = 'filter';
  static const filters = 'filters';
  static const all = 'all';
  static const allMachines = 'allMachines';
  static const machine = 'machine';
  static const product = 'product';
  static const quantity = 'quantity';
  static const notes = 'notes';
  static const date = 'date';
  static const time = 'time';
  static const total = 'total';
  static const yes = 'yes';
  static const no = 'no';
  static const required = 'required';
  static const view = 'view';
  static const loading = 'loading';
  static const error = 'error';
  static const retry = 'retry';
  static const noData = 'noData';
  static const noRecordsYet = 'noRecordsYet';
  static const confirmDelete = 'confirmDelete';
  static const confirmDeleteProduct = 'confirmDeleteProduct';
  static const confirmDeleteMachine = 'confirmDeleteMachine';
  static const confirmRestore = 'confirmRestore';
  static const confirmRestoreTitle = 'confirmRestoreTitle';

  // Forms
  static const addSale = 'addSale';
  static const editSale = 'editSale';
  static const addRestocking = 'addRestocking';
  static const editRestocking = 'editRestocking';
  static const addChangeAdded = 'addChangeAdded';
  static const editChangeAdded = 'editChangeAdded';
  static const addCashReading = 'addCashReading';
  static const editCashReading = 'editCashReading';
  static const addReconciliation = 'addReconciliation';
  static const editReconciliation = 'editReconciliation';
  static const selectRecordType = 'selectRecordType';
  static const selectMachine = 'selectMachine';
  static const selectProduct = 'selectProduct';
  static const noProduct = 'noProduct';
  static const unitPrice = 'unitPrice';
  static const costPrice = 'costPrice';
  static const sellingPrice = 'sellingPrice';
  static const purchasePrice = 'purchasePrice';
  static const unitCost = 'unitCost';
  static const amount = 'amount';
  static const readingAmount = 'readingAmount';
  static const expected = 'expected';
  static const actual = 'actual';
  static const difference = 'difference';
  static const currency = 'currency';
  static const mustBeGreaterThanZero = 'mustBeGreaterThanZero';
  static const mustBeNonNegative = 'mustBeNonNegative';
  static const commissionRange = 'commissionRange';
  static const pleaseSelectMachine = 'pleaseSelectMachine';

  // Machines
  static const name = 'name';
  static const code = 'code';
  static const location = 'location';
  static const status = 'status';
  static const active = 'active';
  static const inactive = 'inactive';
  static const installedAt = 'installedAt';
  static const commissionPercent = 'commissionPercent';
  static const addMachine = 'addMachine';
  static const editMachine = 'editMachine';
  static const saveMachine = 'saveMachine';
  static const machineName = 'machineName';
  static const machineCode = 'machineCode';
  static const noMachinesYet = 'noMachinesYet';

  // Inventory / products
  static const category = 'category';
  static const stock = 'stock';
  static const currentStock = 'currentStock';
  static const minimumStock = 'minimumStock';
  static const inStock = 'inStock';
  static const lowStock = 'lowStock';
  static const outOfStock = 'outOfStock';
  static const addProduct = 'addProduct';
  static const editProduct = 'editProduct';
  static const productName = 'productName';
  static const noProductsYet = 'noProductsYet';

  // Dashboard
  static const overview = 'overview';
  static const today = 'today';
  static const thisMonth = 'thisMonth';
  static const totalSales = 'totalSales';
  static const totalMachines = 'totalMachines';
  static const activeMachines = 'activeMachines';
  static const lowStockProducts = 'lowStockProducts';
  static const topMachines = 'topMachines';
  static const quickActions = 'quickActions';
  static const manageMachines = 'manageMachines';
  static const last7Days = 'last7Days';
  static const last30Days = 'last30Days';

  // Machine details
  static const machineDashboard = 'machineDashboard';
  static const todaySales = 'todaySales';
  static const thisMonthSales = 'thisMonthSales';
  static const thisMonthProfit = 'thisMonthProfit';
  static const thisMonthCommission = 'thisMonthCommission';
  static const transactions = 'transactions';
  static const cash = 'cash';
  static const expectedCash = 'expectedCash';
  static const actualCash = 'actualCash';
  static const inventorySummary = 'inventorySummary';
  static const products = 'products';
  static const salesTrend = 'salesTrend';
  static const profitTrend = 'profitTrend';
  static const recordsFilter = 'recordsFilter';
  static const filterRecords = 'filterRecords';
  static const noRecordsForMachine = 'noRecordsForMachine';

  // Reports
  static const reportFilters = 'reportFilters';
  static const dateRange = 'dateRange';
  static const reportType = 'reportType';
  static const quickFilters = 'quickFilters';
  static const thisWeek = 'thisWeek';
  static const lastMonth = 'lastMonth';
  static const thisYear = 'thisYear';
  static const custom = 'custom';
  static const summary = 'summary';
  static const grossProfit = 'grossProfit';
  static const netProfit = 'netProfit';
  static const totalCommission = 'totalCommission';
  static const avgSale = 'avgSale';
  static const salesReport = 'salesReport';
  static const bestSellingProduct = 'bestSellingProduct';
  static const bestMachine = 'bestMachine';
  static const lowestMachine = 'lowestMachine';
  static const machinePerformance = 'machinePerformance';
  static const productPerformance = 'productPerformance';
  static const commissionReport = 'commissionReport';
  static const cashReport = 'cashReport';
  static const restockingReport = 'restockingReport';
  static const profitReport = 'profitReport';
  static const revenue = 'revenue';
  static const productCost = 'productCost';
  static const exportPdf = 'exportPdf';
  static const exportExcel = 'exportExcel';
  static const performance = 'performance';
  static const quantitySold = 'quantitySold';
  static const sortBy = 'sortBy';
  static const fromDate = 'fromDate';
  static const toDate = 'toDate';
  static const totalRestockingCost = 'totalRestockingCost';
  static const totalItemsRestocked = 'totalItemsRestocked';
  static const bestPerformingMachine = 'bestPerformingMachine';
  static const lowestPerformingMachine = 'lowestPerformingMachine';
  static const currentMonth = 'currentMonth';

  // Import / Export / Backup
  static const importCsv = 'importCsv';
  static const exportBackup = 'exportBackup';
  static const restoreBackup = 'restoreBackup';
  static const importSummary = 'importSummary';
  static const imported = 'imported';
  static const skipped = 'skipped';
  static const errors = 'errors';
  static const duplicateImport = 'duplicateImport';
  static const backupCreated = 'backupCreated';
  static const restoreComplete = 'restoreComplete';
  static const exportSuccess = 'exportSuccess';
  static const exportFail = 'exportFail';
  static const savedToDownloads = 'savedToDownloads';

  // Settings / language
  static const language = 'language';
  static const arabic = 'arabic';
  static const english = 'english';
  static const switchToArabic = 'switchToArabic';
  static const switchToEnglish = 'switchToEnglish';
  static const about = 'about';
  static const version = 'version';
  static const tagline = 'tagline';
  static const noMachineSelected = 'noMachineSelected';
  static const editDetails = 'editDetails';
  static const viewReports = 'viewReports';
  static const thisMonthSalesShort = 'thisMonthSalesShort';
  static const totalProducts = 'totalProducts';
  static const activeProducts = 'activeProducts';
  static const totalRestocked = 'totalRestocked';
  static const thisYearProfit = 'thisYearProfit';
}

class AppStrings {
  static const en = {
    // Navigation
    'dashboard': 'Dashboard',
    'machines': 'Machines',
    'records': 'Records',
    'inventory': 'Inventory',
    'reports': 'Reports',
    'settings': 'Settings',

    // Record types
    'sales': 'Sales',
    'restocking': 'Restocking',
    'changeAdded': 'Change Added',
    'cashReading': 'Cash Reading',
    'reconciliation': 'Reconciliation',
    'cashCollection': 'Cash Collection',
    'profit': 'Profit',
    'commission': 'Commission',

    // Cash collection
    'addCashCollection': 'Add Cash Collection',
    'editCashCollection': 'Edit Cash Collection',
    'collectCash': 'Collect Cash',
    'collectedAmount': 'Collected Amount',
    'collectionsTrend': 'Cash Collections Trend',
    'collected': 'Collected',

    // Sales receipt
    'salesReceipt': 'Sales Receipt',
    'selectMonth': 'Select Month',
    'receiptDetails': 'Receipt Details',
    'monthlyTotals': 'Monthly Totals',
    'cashCollections': 'Cash Collections',
    'dailyLedger': 'Daily Ledger',
    'net': 'Net',
    'month': 'Month',
    'noMachinesReceipt': 'No machines available for this month.',
    'totalCollectedCash': 'Total Collected Cash',
    'totalAddedChange': 'Total Added Change',
    'netAmount': 'NET AMOUNT',
    'commissionAmount': 'Commission Amount',
    'cashCollectionsShort': 'Collected',
    'type': 'Type',

    // Spending
    'spendingRecords': 'Spending Records',
    'inventorySpending': 'Inventory Spending',
    'utilitiesSpending': 'Utilities Spending',
    'totalSpending': 'Total Spending',
    'totalSpendingThisMonth': 'Total Spending This Month',
    'addSpending': 'Add Spending',
    'editSpending': 'Edit Spending',
    'deleteSpending': 'Delete Spending',
    'selectSpendingType': 'Select Spending Type',
    'spendingType': 'Spending Type',
    'supplier': 'Supplier',
    'utilityType': 'Utility Type',
    'description': 'Description',
    'referenceNumber': 'Reference Number',
    'spending': 'Spending',
    'addInventorySpending': 'Add Inventory Spending',
    'editInventorySpending': 'Edit Inventory Spending',
    'addUtilitiesSpending': 'Add Utilities Spending',
    'editUtilitiesSpending': 'Edit Utilities Spending',
    'confirmDeleteSpending':
        'Are you sure you want to delete this spending record?',
    'noSpendingRecords': 'No spending records found.',
    'electricity': 'Electricity',
    'water': 'Water',
    'internet': 'Internet',
    'fuel': 'Fuel',
    'transportation': 'Transportation',
    'maintenance': 'Maintenance',
    'other': 'Other',
    'collectedAmountHint': 'How much cash was collected from the machine',
    'cashCollectionInfo':
        'Record every time cash is collected from the machine. This is your main collection log.',

    // Common
    'add': 'Add',
    'addRecord': 'Add Record',
    'edit': 'Edit',
    'delete': 'Delete',
    'save': 'Save',
    'cancel': 'Cancel',
    'close': 'Close',
    'search': 'Search',
    'filter': 'Filter',
    'filters': 'Filters',
    'all': 'All',
    'allMachines': 'All Machines',
    'machine': 'Machine',
    'product': 'Product',
    'quantity': 'Quantity',
    'notes': 'Notes',
    'date': 'Date',
    'time': 'Time',
    'total': 'Total',
    'yes': 'Yes',
    'no': 'No',
    'required': 'Required',
    'view': 'View',
    'loading': 'Loading…',
    'error': 'Something went wrong',
    'retry': 'Retry',
    'noData': 'No data available for this period.',
    'noRecordsYet': 'No records yet.',
    'confirmDelete': 'Are you sure you want to delete this record?',
    'confirmDeleteProduct': 'Are you sure you want to delete this product?',
    'confirmDeleteMachine': 'Are you sure you want to delete this machine?',
    'confirmRestore': 'Restoring will replace all current data. Continue?',
    'confirmRestoreTitle': 'Restore backup',

    // Forms
    'addSale': 'Add Sale',
    'editSale': 'Edit Sale',
    'addRestocking': 'Add Restocking',
    'editRestocking': 'Edit Restocking',
    'addChangeAdded': 'Add Change Added',
    'editChangeAdded': 'Edit Change Added',
    'addCashReading': 'Add Cash Reading',
    'editCashReading': 'Edit Cash Reading',
    'addReconciliation': 'Add Reconciliation',
    'editReconciliation': 'Edit Reconciliation',
    'selectRecordType': 'Select the type of record to add',
    'selectMachine': 'Select a machine',
    'selectProduct': 'Select a product',
    'noProduct': '— No product —',
    'unitPrice': 'Unit Price',
    'costPrice': 'Cost Price',
    'sellingPrice': 'Selling Price',
    'purchasePrice': 'Purchase Price',
    'unitCost': 'Unit Cost',
    'amount': 'Amount',
    'readingAmount': 'Reading Amount',
    'expected': 'Expected',
    'actual': 'Actual',
    'difference': 'Difference',
    'currency': 'LYD',
    'mustBeGreaterThanZero': 'Must be greater than 0',
    'mustBeNonNegative': 'Must be 0 or more',
    'commissionRange': 'Must be between 0 and 100',
    'pleaseSelectMachine': 'Please select a machine',

    // Machines
    'name': 'Name',
    'code': 'Code',
    'location': 'Location',
    'status': 'Status',
    'active': 'Active',
    'inactive': 'Inactive',
    'installedAt': 'Installation Date',
    'commissionPercent': 'Commission %',
    'addMachine': 'Add Machine',
    'editMachine': 'Edit Machine',
    'saveMachine': 'Save Machine',
    'machineName': 'Machine Name',
    'machineCode': 'Machine Code',
    'noMachinesYet': 'No machines yet. Add your first machine to get started.',

    // Inventory / products
    'category': 'Category',
    'stock': 'Stock',
    'currentStock': 'Current Stock',
    'minimumStock': 'Minimum Stock',
    'inStock': 'In Stock',
    'lowStock': 'Low Stock',
    'outOfStock': 'Out of Stock',
    'addProduct': 'Add Product',
    'editProduct': 'Edit Product',
    'productName': 'Product Name',
    'noProductsYet': 'No products yet. Add your first product to get started.',

    // Dashboard
    'overview': 'Overview',
    'today': 'Today',
    'thisMonth': 'This Month',
    'totalSales': 'Total Sales',
    'totalMachines': 'Total Machines',
    'activeMachines': 'Active Machines',
    'lowStockProducts': 'Low Stock Products',
    'topMachines': 'Top Machines by Sales',
    'quickActions': 'Quick Actions',
    'manageMachines': 'Manage Machines',
    'last7Days': 'Last 7 Days',
    'last30Days': 'Last 30 Days',

    // Machine details
    'machineDashboard': 'Machine Dashboard',
    'todaySales': 'Today Sales',
    'thisMonthSales': 'This Month Sales',
    'thisMonthProfit': 'This Month Profit',
    'thisMonthCommission': 'This Month Commission',
    'transactions': 'Transactions',
    'cash': 'Cash',
    'expectedCash': 'Expected Cash',
    'actualCash': 'Actual Cash',
    'inventorySummary': 'Inventory',
    'products': 'Products',
    'salesTrend': 'Sales Trend',
    'profitTrend': 'Profit Trend',
    'recordsFilter': 'Records Filter',
    'filterRecords': 'Filter records',
    'noRecordsForMachine': 'No records for this machine yet.',

    // Reports
    'reportFilters': 'Report Filters',
    'dateRange': 'Date Range',
    'reportType': 'Report Type',
    'quickFilters': 'Quick Filters',
    'thisWeek': 'This Week',
    'lastMonth': 'Last Month',
    'thisYear': 'This Year',
    'custom': 'Custom',
    'summary': 'Summary',
    'grossProfit': 'Gross Profit',
    'netProfit': 'Net Profit',
    'totalCommission': 'Total Commission',
    'avgSale': 'Average Sale',
    'salesReport': 'Sales Report',
    'bestSellingProduct': 'Best Selling Product',
    'bestMachine': 'Best Machine',
    'lowestMachine': 'Lowest Performing Machine',
    'machinePerformance': 'Machine Performance',
    'productPerformance': 'Product Performance',
    'commissionReport': 'Commission Report',
    'cashReport': 'Cash Report',
    'collectionReport': 'Cash Collection Report',
    'totalCollected': 'Total Collected',
    'collectionCount': 'Collections',
    'restockingReport': 'Restocking Report',
    'profitReport': 'Profit Report',
    'revenue': 'Revenue',
    'productCost': 'Product Cost',
    'exportPdf': 'Export PDF',
    'exportExcel': 'Export Excel',
    'performance': 'Performance',
    'quantitySold': 'Quantity Sold',
    'sortBy': 'Sort by',
    'fromDate': 'From',
    'toDate': 'To',
    'totalRestockingCost': 'Total Restocking Cost',
    'totalItemsRestocked': 'Total Items Restocked',
    'bestPerformingMachine': 'Best Performing Machine',
    'lowestPerformingMachine': 'Lowest Performing Machine',
    'currentMonth': 'Current Month',

    // Import / Export / Backup
    'importCsv': 'Import CSV',
    'exportBackup': 'Export Backup',
    'restoreBackup': 'Restore Backup',
    'importSummary': 'Import Summary',
    'imported': 'Imported',
    'skipped': 'Skipped',
    'errors': 'Errors',
    'duplicateImport': 'Duplicate rows were skipped.',
    'backupCreated': 'Backup created successfully',
    'restoreComplete': 'Restore completed successfully',
    'exportSuccess': 'Export completed',
    'exportFail': 'Export failed',
    'savedToDownloads': 'Saved to Downloads',

    // Settings / language
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    'switchToArabic': 'Switch to Arabic',
    'switchToEnglish': 'Switch to English',
    'about': 'About',
    'version': 'Version',
    'tagline': 'YOUR BREAK, OUR BUSINESS.',
    'noMachineSelected': 'No machine selected',
    'editDetails': 'Edit Details',
    'viewReports': 'View Reports',
    'thisMonthSalesShort': 'This Month',
    'totalProducts': 'Total Products',
    'activeProducts': 'Active Products',
    'totalRestocked': 'Total Restocked',
    'thisYearProfit': 'This Year Profit',
    'refresh': 'Refresh',
    'uncategorized': 'Uncategorized',
    'lastSync': 'Last Sync',
    'theme': 'Theme',
    'darkMode': 'Dark Mode',
    'lightMode': 'Light Mode',
  };

  static const ar = {
    // Navigation
    'dashboard': 'لوحة القيادة',
    'machines': 'الماكينات',
    'records': 'السجلات',
    'inventory': 'المخزون',
    'reports': 'التقارير',
    'settings': 'الإعدادات',

    // Record types
    'sales': 'المبيعات',
    'restocking': 'إعادة التعبئة',
    'changeAdded': 'فكة مضافة',
    'cashReading': 'قراءة النقدية',
    'reconciliation': 'التسوية',
    'cashCollection': 'تحصيل النقدية',
    'profit': 'الربح',
    'commission': 'العمولة',

    // Cash collection
    'addCashCollection': 'إضافة تحصيل نقدية',
    'editCashCollection': 'تعديل تحصيل النقدية',
    'collectCash': 'تحصيل نقدية',
    'collectedAmount': 'المبلغ المحصّل',
    'collectionsTrend': 'اتجاه تحصيل النقدية',
    'collected': 'المحصّل',

    // Sales receipt
    'salesReceipt': 'إيصال المبيعات',
    'selectMonth': 'اختر الشهر',
    'receiptDetails': 'تفاصيل الإيصال',
    'monthlyTotals': 'إجماليات الشهر',
    'cashCollections': 'تحصيلات النقدية',
    'dailyLedger': 'السجل اليومي',
    'net': 'الصافي',
    'month': 'الشهر',
    'noMachinesReceipt': 'لا توجد ماكينات متاحة لهذا الشهر.',
    'totalCollectedCash': 'إجمالي النقدية المحصّلة',
    'totalAddedChange': 'إجمالي الفكة المضافة',
    'netAmount': 'صافي المبلغ',
    'commissionAmount': 'مبلغ العمولة',
    'cashCollectionsShort': 'محصّل',
    'type': 'النوع',

    // Spending
    'spendingRecords': 'سجلات المصروفات',
    'inventorySpending': 'مصروفات المخزون',
    'utilitiesSpending': 'مصروفات الخدمات',
    'totalSpending': 'إجمالي المصروفات',
    'totalSpendingThisMonth': 'إجمالي المصروفات هذا الشهر',
    'addSpending': 'إضافة مصروف',
    'editSpending': 'تعديل المصروف',
    'deleteSpending': 'حذف المصروف',
    'selectSpendingType': 'اختر نوع المصروف',
    'spendingType': 'نوع المصروف',
    'supplier': 'المورد',
    'utilityType': 'نوع الخدمة',
    'description': 'الوصف',
    'referenceNumber': 'رقم المرجع',
    'spending': 'المصروفات',
    'addInventorySpending': 'إضافة مصروف مخزون',
    'editInventorySpending': 'تعديل مصروف المخزون',
    'addUtilitiesSpending': 'إضافة مصروف خدمات',
    'editUtilitiesSpending': 'تعديل مصروف الخدمات',
    'confirmDeleteSpending': 'هل أنت متأكد من حذف سجل المصروفات هذا؟',
    'noSpendingRecords': 'لا توجد سجلات مصروفات.',
    'electricity': 'الكهرباء',
    'water': 'المياه',
    'internet': 'الإنترنت',
    'fuel': 'الوقود',
    'transportation': 'النقل',
    'maintenance': 'الصيانة',
    'other': 'أخرى',
    'collectedAmountHint': 'كمية النقدية المحصّلة من الماكينة',
    'cashCollectionInfo':
        'سجّل كل مرة يتم فيها تحصيل النقدية من الماكينة. هذا هو سجل التحصيل الرئيسي.',

    // Common
    'add': 'إضافة',
    'addRecord': 'إضافة سجل',
    'edit': 'تعديل',
    'delete': 'حذف',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'close': 'إغلاق',
    'search': 'بحث',
    'filter': 'تصفية',
    'filters': 'التصفية',
    'all': 'الكل',
    'allMachines': 'كل الماكينات',
    'machine': 'الماكينة',
    'product': 'المنتج',
    'quantity': 'الكمية',
    'notes': 'ملاحظات',
    'date': 'التاريخ',
    'time': 'الوقت',
    'total': 'الإجمالي',
    'yes': 'نعم',
    'no': 'لا',
    'required': 'مطلوب',
    'view': 'عرض',
    'loading': 'جارٍ التحميل…',
    'error': 'حدث خطأ ما',
    'retry': 'إعادة المحاولة',
    'noData': 'لا توجد بيانات لهذه الفترة.',
    'noRecordsYet': 'لا توجد سجلات بعد.',
    'confirmDelete': 'هل أنت متأكد من حذف هذا السجل؟',
    'confirmDeleteProduct': 'هل أنت متأكد من حذف هذا المنتج؟',
    'confirmDeleteMachine': 'هل أنت متأكد من حذف هذه الماكينة؟',
    'confirmRestore': 'ستتم الاستعادة وستحل محل جميع البيانات الحالية. متابعة؟',
    'confirmRestoreTitle': 'استعادة نسخة احتياطية',

    // Forms
    'addSale': 'إضافة مبيعات',
    'editSale': 'تعديل المبيعات',
    'addRestocking': 'إضافة إعادة تعبئة',
    'editRestocking': 'تعديل إعادة التعبئة',
    'addChangeAdded': 'إضافة فكة مضافة',
    'editChangeAdded': 'تعديل الفكة المضافة',
    'addCashReading': 'إضافة قراءة نقدية',
    'editCashReading': 'تعديل القراءة النقدية',
    'addReconciliation': 'إضافة تسوية',
    'editReconciliation': 'تعديل تسوية',
    'selectRecordType': 'اختر نوع السجل المراد إضافته',
    'selectMachine': 'اختر ماكينة',
    'selectProduct': 'اختر منتجًا',
    'noProduct': '— بدون منتج —',
    'unitPrice': 'سعر الوحدة',
    'costPrice': 'سعر التكلفة',
    'sellingPrice': 'سعر البيع',
    'purchasePrice': 'سعر الشراء',
    'unitCost': 'تكلفة الوحدة',
    'amount': 'المبلغ',
    'readingAmount': 'مبلغ القراءة',
    'expected': 'المتوقع',
    'actual': 'الفعلي',
    'difference': 'الفرق',
    'currency': 'د.ل',
    'mustBeGreaterThanZero': 'يجب أن يكون أكبر من 0',
    'mustBeNonNegative': 'يجب أن يكون 0 أو أكثر',
    'commissionRange': 'يجب أن يكون بين 0 و 100',
    'pleaseSelectMachine': 'الرجاء اختيار ماكينة',

    // Machines
    'name': 'الاسم',
    'code': 'الرمز',
    'location': 'الموقع',
    'status': 'الحالة',
    'active': 'نشط',
    'inactive': 'غير نشط',
    'installedAt': 'تاريخ التركيب',
    'commissionPercent': 'نسبة العمولة %',
    'addMachine': 'إضافة ماكينة',
    'editMachine': 'تعديل ماكينة',
    'saveMachine': 'حفظ الماكينة',
    'machineName': 'اسم الماكينة',
    'machineCode': 'رمز الماكينة',
    'noMachinesYet': 'لا توجد ماكينات بعد. أضف أول ماكينة للبدء.',

    // Inventory / products
    'category': 'الفئة',
    'stock': 'المخزون',
    'currentStock': 'المخزون الحالي',
    'minimumStock': 'الحد الأدنى للمخزون',
    'inStock': 'متوفر',
    'lowStock': 'مخزون منخفض',
    'outOfStock': 'غير متوفر',
    'addProduct': 'إضافة منتج',
    'editProduct': 'تعديل منتج',
    'productName': 'اسم المنتج',
    'noProductsYet': 'لا توجد منتجات بعد. أضف أول منتج للبدء.',

    // Dashboard
    'overview': 'نظرة عامة',
    'today': 'اليوم',
    'thisMonth': 'هذا الشهر',
    'totalSales': 'إجمالي المبيعات',
    'totalMachines': 'إجمالي الماكينات',
    'activeMachines': 'الماكينات النشطة',
    'lowStockProducts': 'منتجات المخزون المنخفض',
    'topMachines': 'أفضل الماكينات مبيعًا',
    'quickActions': 'إجراءات سريعة',
    'manageMachines': 'إدارة الماكينات',
    'last7Days': 'آخر 7 أيام',
    'last30Days': 'آخر 30 يومًا',

    // Machine details
    'machineDashboard': 'لوحة الماكينة',
    'todaySales': 'مبيعات اليوم',
    'thisMonthSales': 'مبيعات هذا الشهر',
    'thisMonthProfit': 'ربح هذا الشهر',
    'thisMonthCommission': 'عمولة هذا الشهر',
    'transactions': 'المعاملات',
    'cash': 'النقدية',
    'expectedCash': 'النقدية المتوقعة',
    'actualCash': 'النقدية الفعلية',
    'inventorySummary': 'المخزون',
    'products': 'المنتجات',
    'salesTrend': 'اتجاه المبيعات',
    'profitTrend': 'اتجاه الربح',
    'recordsFilter': 'تصفية السجلات',
    'filterRecords': 'تصفية السجلات',
    'noRecordsForMachine': 'لا توجد سجلات لهذه الماكينة بعد.',

    // Reports
    'reportFilters': 'تصفية التقرير',
    'dateRange': 'نطاق التاريخ',
    'reportType': 'نوع التقرير',
    'quickFilters': 'تصفية سريعة',
    'thisWeek': 'هذا الأسبوع',
    'lastMonth': 'الشهر الماضي',
    'thisYear': 'هذه السنة',
    'custom': 'مخصص',
    'summary': 'الملخص',
    'grossProfit': 'الربح الإجمالي',
    'netProfit': 'صافي الربح',
    'totalCommission': 'إجمالي العمولة',
    'avgSale': 'متوسط البيع',
    'salesReport': 'تقرير المبيعات',
    'bestSellingProduct': 'المنتج الأكثر مبيعًا',
    'bestMachine': 'أفضل ماكينة',
    'lowestMachine': 'الماكينة الأقل أداء',
    'machinePerformance': 'أداء الماكينات',
    'productPerformance': 'أداء المنتجات',
    'commissionReport': 'تقرير العمولات',
    'cashReport': 'تقرير النقدية',
    'collectionReport': 'تقرير تحصيل النقدية',
    'totalCollected': 'إجمالي المحصّل',
    'collectionCount': 'عدد عمليات التحصيل',
    'restockingReport': 'تقرير إعادة التعبئة',
    'profitReport': 'تقرير الربح',
    'revenue': 'الإيرادات',
    'productCost': 'تكلفة المنتجات',
    'exportPdf': 'تصدير PDF',
    'exportExcel': 'تصدير Excel',
    'performance': 'الأداء',
    'quantitySold': 'الكمية المباعة',
    'sortBy': 'ترتيب حسب',
    'fromDate': 'من',
    'toDate': 'إلى',
    'totalRestockingCost': 'إجمالي تكلفة إعادة التعبئة',
    'totalItemsRestocked': 'إجمالي العناصر المعاد تعبئتها',
    'bestPerformingMachine': 'الماكينة الأفضل أداءً',
    'lowestPerformingMachine': 'الماكينة الأقل أداءً',
    'currentMonth': 'الشهر الحالي',

    // Import / Export / Backup
    'importCsv': 'استيراد CSV',
    'exportBackup': 'تصدير نسخة احتياطية',
    'restoreBackup': 'استعادة نسخة احتياطية',
    'importSummary': 'ملخص الاستيراد',
    'imported': 'تم الاستيراد',
    'skipped': 'تم التجاهل',
    'errors': 'أخطاء',
    'duplicateImport': 'تم تجاهل الصفوف المكررة.',
    'backupCreated': 'تم إنشاء النسخة الاحتياطية بنجاح',
    'restoreComplete': 'تمت الاستعادة بنجاح',
    'exportSuccess': 'اكتمل التصدير',
    'exportFail': 'فشل التصدير',
    'savedToDownloads': 'تم الحفظ في التنزيلات',

    // Settings / language
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'switchToArabic': 'التبديل إلى العربية',
    'switchToEnglish': 'التبديل إلى الإنجليزية',
    'about': 'حول',
    'version': 'الإصدار',
    'tagline': 'استراحتك، عملنا.',
    'noMachineSelected': 'لم يتم اختيار ماكينة',
    'editDetails': 'تعديل التفاصيل',
    'viewReports': 'عرض التقارير',
    'thisMonthSalesShort': 'هذا الشهر',
    'totalProducts': 'إجمالي المنتجات',
    'activeProducts': 'المنتجات النشطة',
    'totalRestocked': 'إجمالي إعادة التعبئة',
    'thisYearProfit': 'ربح هذه السنة',
    'refresh': 'تحديث',
    'uncategorized': 'غير مصنف',
    'lastSync': 'آخر مزامنة',
    'theme': 'المظهر',
    'darkMode': 'الوضع الداكن',
    'lightMode': 'الوضع الفاتح',
  };
}
