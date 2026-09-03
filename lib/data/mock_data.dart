import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/lesson.dart';
import '../models/member.dart';
import '../models/project.dart';

/// بيانات وهمية مؤقتة لبناء الواجهة قبل ربطها بـ Supabase.
class MockData {
  MockData._();

  static const currentUserName = 'أحمد الطالب';
  static const currentUserEmail = 'ahmed@example.com';

  static const projects = <CharityProject>[
    CharityProject(
      title: 'مشروع سقيا الأمل',
      subtitle: 'توفير المياه الصالحة للشرب',
      category: 'إغاثية',
      icon: Icons.water_drop_outlined,
      color: Color(0xFF5B9BD5),
      collected: 60000,
      goal: 100000,
    ),
    CharityProject(
      title: 'من أجلهم في رمضان',
      subtitle: 'توزيع السلال الغذائية للأسر المحتاجة',
      category: 'دعم الأسر',
      icon: Icons.food_bank_outlined,
      color: Color(0xFFE0A458),
      collected: 80000,
      goal: 100000,
    ),
    CharityProject(
      title: 'كسوة العيد',
      subtitle: 'توزيع ملابس العيد للأطفال',
      category: 'إغاثية',
      icon: Icons.checkroom_outlined,
      color: Color(0xFFB784D4),
      collected: 50000,
      goal: 50000,
    ),
  ];

  static const lessons = <Lesson>[
    Lesson(
      title: 'أصول العقيدة الإسلامية',
      lessonCount: 12,
      category: 'العقيدة',
      icon: Icons.menu_book_outlined,
    ),
    Lesson(
      title: 'الفقه الميسر',
      lessonCount: 18,
      category: 'الفقه',
      icon: Icons.balance_outlined,
    ),
    Lesson(
      title: 'شرح الحديث النبوي',
      lessonCount: 20,
      category: 'الحديث',
      icon: Icons.auto_stories_outlined,
    ),
    Lesson(
      title: 'سيرة النبي صلى الله عليه وسلم',
      lessonCount: 15,
      category: 'السيرة',
      icon: Icons.history_edu_outlined,
    ),
    Lesson(
      title: 'التفسير الميسر',
      lessonCount: 25,
      category: 'العقيدة',
      icon: Icons.import_contacts_outlined,
    ),
  ];

  static const expenseCategories = <ExpenseCategory>[
    ExpenseCategory(
      name: 'المشاريع الإغاثية',
      percent: 45,
      color: Color(0xFFEC998C),
    ),
    ExpenseCategory(
      name: 'المشاريع التعليمية',
      percent: 25,
      color: Color(0xFF221D3F),
    ),
    ExpenseCategory(
      name: 'دعم الأسر المحتاجة',
      percent: 15,
      color: Color(0xFF5B9BD5),
    ),
    ExpenseCategory(
      name: 'المصاريف الإدارية',
      percent: 15,
      color: Color(0xFFCFC7DE),
    ),
  ];

  static const expenses = <Expense>[
    Expense(
      title: 'شراء مضخة مياه',
      category: 'مشاريع إغاثية',
      amount: 2500,
      date: '2024/05/20',
      paymentMethod: 'تحويل بنكي',
      referenceNumber: '#458721',
      notes: 'تم شراء مضخة مياه لقرية التيسير.',
    ),
    Expense(
      title: 'توزيع سلال غذائية',
      category: 'دعم الأسر المحتاجة',
      amount: 5000,
      date: '2024/05/20',
      paymentMethod: 'تحويل بنكي',
      referenceNumber: '#458690',
    ),
    Expense(
      title: 'مساعدات طبية',
      category: 'المشاريع الإغاثية',
      amount: 1200,
      date: '2024/05/16',
      paymentMethod: 'تحويل بنكي',
      referenceNumber: '#458650',
    ),
    Expense(
      title: 'إيجار مقر الجمعية',
      category: 'المصاريف الإدارية',
      amount: 3000,
      date: '2024/05/15',
      paymentMethod: 'تحويل بنكي',
      referenceNumber: '#458602',
    ),
  ];

  static const totalExpenses = 120750;
  static const expenseOperationsCount = 48;

  static const members = <AssociationMember>[
    AssociationMember(name: 'أحمد الطالب', role: 'رئيس الجمعية'),
    AssociationMember(name: 'محمد الأمين', role: 'نائب الرئيس'),
    AssociationMember(name: 'سيباني محمد', role: 'أمين المال'),
    AssociationMember(name: 'هالة بنت عبد الله', role: 'مسؤول التعليم'),
    AssociationMember(
      name: 'إسلمو المختار',
      role: 'مسؤول المشاريع',
    ),
  ];

  static const affiliates = <AssociationMember>[
    AssociationMember(
      name: 'فاطمة الزهراء',
      role: 'متطوعة',
      isAffiliate: true,
    ),
    AssociationMember(name: 'عبد الرحمن سالم', role: 'متطوع', isAffiliate: true),
  ];
}
