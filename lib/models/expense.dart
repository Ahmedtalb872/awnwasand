import 'package:flutter/material.dart';

/// عملية صرف مالي من ميزانية الجمعية.
class Expense {
  const Expense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.referenceNumber,
    this.notes,
  });

  final String title;
  final String category;
  final int amount;
  final String date;
  final String paymentMethod;
  final String referenceNumber;
  final String? notes;
}

/// فئة إنفاق ونسبتها من إجمالي المصروفات، لعرضها في الرسم الدائري.
class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.percent,
    required this.color,
  });

  final String name;
  final int percent;
  final Color color;
}
