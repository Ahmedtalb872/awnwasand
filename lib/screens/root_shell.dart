import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'lessons_screen.dart';
import 'profile_screen.dart';
import 'subjects_screen.dart';

/// الحاوية الجذرية التي تحمل شريط التنقل السفلي وتبدّل بين الشاشات الرئيسية.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    SubjectsScreen(),
    LessonsScreen(),
    ProfileScreen(),
  ];

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: goTo,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'المكتبة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'دروسي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

/// يعثر على [_RootShellState] الأقرب للتبديل بين التبويبات من شاشة داخلية.
extension RootShellNavigation on BuildContext {
  void goToTab(int index) {
    findAncestorStateOfType<_RootShellState>()?.goTo(index);
  }
}
