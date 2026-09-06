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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      title: map['title'] as String,
      category: map['category'] as String,
      amount: map['amount'] as int,
      date: (map['spent_at'] as String).replaceAll('-', '/'),
      paymentMethod: map['payment_method'] as String,
      referenceNumber: map['reference_number'] as String,
      notes: map['notes'] as String?,
    );
  }

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
