import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/financial_report.dart';
import '../services/supabase_service.dart';

class ExpensesRepository {
  static const _categoryPalette = [
    Color(0xFFEC998C),
    Color(0xFF221D3F),
    Color(0xFF5B9BD5),
    Color(0xFFCFC7DE),
    Color(0xFF3FAE71),
    Color(0xFFE0A458),
  ];

  Future<FinancialReport> fetchReport({int recentLimit = 4}) async {
    final rows = await SupabaseService.client
        .from('expenses')
        .select()
        .order('spent_at', ascending: false);
    final expenses = rows.map(Expense.fromMap).toList();

    final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);

    final byCategory = <String, int>{};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final categories = <ExpenseCategory>[];
    var colorIndex = 0;
    for (final entry in byCategory.entries) {
      final percent = total == 0 ? 0 : ((entry.value / total) * 100).round();
      categories.add(
        ExpenseCategory(
          name: entry.key,
          percent: percent,
          color: _categoryPalette[colorIndex % _categoryPalette.length],
        ),
      );
      colorIndex++;
    }

    return FinancialReport(
      totalExpenses: total,
      operationsCount: expenses.length,
      categories: categories,
      recentExpenses: expenses.take(recentLimit).toList(),
    );
  }
}
