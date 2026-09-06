import 'expense.dart';

/// ملخص التقارير المالية: الإجمالي، عدد العمليات، توزيع الفئات، وآخر المصروفات.
class FinancialReport {
  const FinancialReport({
    required this.totalExpenses,
    required this.operationsCount,
    required this.categories,
    required this.recentExpenses,
  });

  final int totalExpenses;
  final int operationsCount;
  final List<ExpenseCategory> categories;
  final List<Expense> recentExpenses;
}
