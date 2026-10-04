import 'dart:math' as math;
import 'package:flutter/material.dart';

const brandName = 'المحجة البيضاء';
const brandPurple = Color(0xff795cff);
const brandPink = Color(0xffbdb0ff);
const brandIvory = Color(0xff121025);
const brandMuted = Color(0xffaaa5c8);
const brandBorder = Color(0xff37304f);
const brandSurface = Color(0xff211c38);

ThemeData academyTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandPurple, brightness: Brightness.dark).copyWith(
    primary: brandPurple, onPrimary: Colors.white,
    secondary: brandPink, onSecondary: brandIvory,
    surface: brandSurface, onSurface: Colors.white,
    secondaryContainer: const Color(0xff332853),
  );
  return ThemeData(
    useMaterial3: true, fontFamily: 'Cairo', colorScheme: scheme,
    iconTheme: const IconThemeData(color: brandPink),
    chipTheme: ChipThemeData(backgroundColor: brandSurface, selectedColor: const Color(0xff49376e), side: const BorderSide(color: brandBorder), labelStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12)),
    scaffoldBackgroundColor: brandIvory,
    textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 13, height: 1.7), bodyLarge: TextStyle(fontSize: 15, height: 1.6), titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    appBarTheme: const AppBarTheme(backgroundColor: brandIvory, foregroundColor: Colors.white, centerTitle: false, elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 76),
    cardTheme: CardTheme(color: brandSurface, surfaceTintColor: Colors.transparent, elevation: 0, margin: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: brandBorder))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xff1d1933), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17), labelStyle: const TextStyle(color: brandMuted, fontSize: 13), hintStyle: const TextStyle(color: brandMuted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandPurple, width: 1.5))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 56), textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), side: const BorderSide(color: brandBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xff19152e), indicatorColor: Color(0xff423167), elevation: 0, height: 78, labelTextStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600))),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: brandPink, linearTrackColor: Color(0xff38304f), borderRadius: BorderRadius.all(Radius.circular(10))),
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
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [brandPurple, Color(0xff5032b0)])),
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
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: brandSurface, borderRadius: BorderRadius.circular(24), border: Border.all(color: brandBorder)), child: Column(children: [Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: brandIvory, shape: BoxShape.circle), child: Icon(icon, size: 30, color: brandMuted)), const SizedBox(height: 16), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(description, textAlign: TextAlign.center, style: const TextStyle(color: brandMuted, fontSize: 12))]));
}


class GlowButton extends StatelessWidget {
  const GlowButton({super.key, required this.onPressed, required this.child});
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: onPressed == null ? [brandBorder, brandBorder] : const [Color(0xffb0a0ff), Color(0xff795cff)]), boxShadow: onPressed == null ? [] : [BoxShadow(color: brandPurple.withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 8))]),
    child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, foregroundColor: brandIvory, disabledForegroundColor: brandMuted, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: onPressed, child: child),
  );
}

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.register});
  final bool register;
  @override
  Widget build(BuildContext context) => ClipPath(clipper: const HeroCurve(), child: Container(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 38),
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff8360ff), Color(0xff4726d1)])),
    child: Stack(alignment: Alignment.center, children: [
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: GeometryPainter()))),
      Column(children: [
        SizedBox(height: 106, child: Stack(alignment: Alignment.center, children: [
          Positioned(right: 32, top: 10, child: Transform.rotate(angle: 0.16, child: Container(width: 76, height: 86, decoration: BoxDecoration(color: const Color(0xffded7ff).withValues(alpha: 0.27), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24)), child: const Icon(Icons.bookmark_outlined, color: Colors.white70, size: 34)))),
          Transform.rotate(angle: -0.12, child: Container(width: 110, height: 82, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xfff7efff), Color(0xffb6a5ff)]), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x40321c7e), blurRadius: 24, offset: Offset(0, 10))]), child: const Icon(Icons.auto_stories, size: 54, color: Color(0xff5535b7)))),
          const Positioned(left: 25, top: 4, child: Icon(Icons.auto_awesome, size: 21, color: Colors.white)),
          const Positioned(right: 18, bottom: 6, child: Icon(Icons.star_outline, size: 17, color: Colors.white70)),
        ])),
        const SizedBox(height: 12), Text(register ? 'ابدأ رحلة علم' : 'مرحبًا بعودتك', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4), Text(register ? 'حسابك الأول، وخطوتك نحو علم نافع.' : 'دروسك ومراجعك بانتظارك.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    ]),
  )));
}

class HeroCurve extends CustomClipper<Path> {
  const HeroCurve();
  @override
  Path getClip(Size size) => Path()..lineTo(0, size.height - 32)..quadraticBezierTo(size.width / 2, size.height + 18, size.width, size.height - 32)..lineTo(size.width, 0)..close();
  @override
  bool shouldReclip(HeroCurve oldClipper) => false;
}
