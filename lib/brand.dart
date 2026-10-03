import 'dart:math' as math;
import 'package:flutter/material.dart';

const brandName = 'المحجة البيضاء';
const brandPurple = Color(0xff2b274b);
const brandPink = Color(0xffddaeb5);
const brandIvory = Color(0xfff8f7fb);
const brandMuted = Color(0xff858195);
const brandBorder = Color(0xffeceaf2);

ThemeData academyTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandPurple).copyWith(
    primary: brandPurple, onPrimary: Colors.white,
    secondary: brandPink, onSecondary: brandPurple,
    surface: Colors.white, onSurface: brandPurple,
    secondaryContainer: const Color(0xfff5e1e4),
  );
  return ThemeData(
    useMaterial3: true, fontFamily: 'Arabic', colorScheme: scheme,
    scaffoldBackgroundColor: brandIvory,
    textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 13, height: 1.7), bodyLarge: TextStyle(fontSize: 15, height: 1.6), titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    appBarTheme: const AppBarTheme(backgroundColor: brandIvory, foregroundColor: brandPurple, centerTitle: false, elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 76),
    cardTheme: CardTheme(color: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0, margin: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: brandBorder))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xfff5f4f8), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17), labelStyle: const TextStyle(color: brandMuted, fontSize: 13), hintStyle: const TextStyle(color: brandMuted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandPurple, width: 1.5))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 56), textStyle: const TextStyle(fontFamily: 'Arabic', fontSize: 14, fontWeight: FontWeight.w700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), side: const BorderSide(color: brandBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: Color(0xfff0eaf5), elevation: 0, height: 78, labelTextStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Arabic', fontSize: 11, fontWeight: FontWeight.w600))),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: brandPink, linearTrackColor: Color(0xffeeebf4), borderRadius: BorderRadius.all(Radius.circular(10))),
    dividerTheme: const DividerThemeData(color: brandBorder),
  );
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 220});
  final double width;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.asset('assets/brand/logo.jpg', width: width, height: width / 1.85,
      fit: BoxFit.cover, alignment: const Alignment(0, 0.05), semanticLabel: '$brandName للعلوم الشرعية'),
  );
}

class BrandHeading extends StatelessWidget {
  const BrandHeading({super.key});
  @override
  Widget build(BuildContext context) => const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
    Text(brandName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    Text('مساحتك لطلب العلم', style: TextStyle(fontSize: 10, color: brandMuted)),
  ]);
}

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key, required this.child, this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(28), child: Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [brandPurple, Color(0xff4a416c)])),
    child: Stack(children: [Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: GeometryPainter()))), Padding(padding: padding, child: child)]),
  ));
}

class GeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.06)..style = PaintingStyle.stroke..strokeWidth = 1;
    final center = Offset(size.width + 4, 30);
    for (var radius = 36.0; radius < 230; radius += 32) {
      final path = Path();
      for (var i = 0; i <= 16; i++) {
        final angle = i * math.pi / 8;
        final r = i.isEven ? radius : radius * 0.78;
        final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) { path.moveTo(point.dx, point.dy); } else { path.lineTo(point.dx, point.dy); }
      }
      canvas.drawPath(path..close(), paint);
    }
    canvas.drawCircle(Offset(-20, size.height + 24), 120, paint);
    canvas.drawCircle(Offset(-20, size.height + 24), 150, paint);
  }
  @override
  bool shouldRepaint(GeometryPainter oldDelegate) => false;
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 26, bottom: 12), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(fontSize: 12)))]));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title, description;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: brandBorder)), child: Column(children: [Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: brandIvory, shape: BoxShape.circle), child: Icon(icon, size: 30, color: brandMuted)), const SizedBox(height: 16), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(description, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted, fontSize: 12))]));
}
