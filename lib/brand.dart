import 'dart:math' as math;
import 'package:flutter/material.dart';

const brandName = 'المحجة البيضاء';
const brandPurple = Color(0xff302c50);
const brandPink = Color(0xffd99bab);
const brandIvory = Color(0xfffaf8fc);
const brandMuted = Color(0xff888397);
const brandBorder = Color(0xffebe7f0);
const brandSurface = Color(0xffffffff);

ThemeData academyTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandPurple, brightness: Brightness.light).copyWith(
    primary: brandPurple, onPrimary: Colors.white,
    secondary: brandPink, onSecondary: brandIvory,
    surface: brandSurface, onSurface: brandPurple,
    secondaryContainer: const Color(0xfff5e9ef),
  );
  return ThemeData(
    useMaterial3: true, fontFamily: 'Cairo', colorScheme: scheme,
    iconTheme: const IconThemeData(color: brandPink),
    chipTheme: ChipThemeData(backgroundColor: brandSurface, selectedColor: const Color(0xffefdce5), side: const BorderSide(color: brandBorder), labelStyle: const TextStyle(fontFamily: 'Cairo', color: brandPurple, fontSize: 12)),
    scaffoldBackgroundColor: brandIvory,
    textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 13, height: 1.7), bodyLarge: TextStyle(fontSize: 15, height: 1.6), titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    appBarTheme: const AppBarTheme(backgroundColor: brandIvory, foregroundColor: brandPurple, centerTitle: false, elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 76),
    cardTheme: CardTheme(color: brandSurface, surfaceTintColor: Colors.transparent, elevation: 0, margin: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: brandBorder))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xfff5f3f9), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17), labelStyle: const TextStyle(color: brandMuted, fontSize: 13), hintStyle: const TextStyle(color: brandMuted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brandPurple, width: 1.5))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 56), textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), side: const BorderSide(color: brandBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xffffffff), indicatorColor: Color(0xfff3dce5), elevation: 0, height: 78, iconTheme: WidgetStatePropertyAll(IconThemeData(color: brandPink, size: 24)), labelTextStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600))),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: brandPink, linearTrackColor: Color(0xffeee8f2), borderRadius: BorderRadius.all(Radius.circular(10))),
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
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff3d365e), Color(0xff292644)])),
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
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: onPressed == null ? [brandBorder, brandBorder] : const [Color(0xff40395f), Color(0xff302c50)]), boxShadow: onPressed == null ? [] : [BoxShadow(color: brandPurple.withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 8))]),
    child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, foregroundColor: Colors.white, disabledForegroundColor: brandMuted, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: onPressed, child: child),
  );
}

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.register});
  final bool register;
  @override
  Widget build(BuildContext context) => Column(children: [
    const LogoMedallion(size: 216),
    const SizedBox(height: 12),
    Text(register ? 'إنشاء حساب جديد' : 'مرحبًا بك', style: const TextStyle(color: brandPurple, fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text(register ? 'انضم إلى المحجة البيضاء\nوابدأ رحلتك في طلب العلم' : 'ابدأ رحلتك مع المحجة البيضاء\nفي طلب العلم', textAlign: TextAlign.center, style: const TextStyle(color: brandMuted, fontSize: 13)),
  ]);
}

class LogoMedallion extends StatelessWidget {
  const LogoMedallion({super.key, this.size = 280});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: OrbitPainter(), child: Padding(padding: EdgeInsets.all(size * .09), child: ClipOval(child: Image.asset('assets/brand/logo.jpg', fit: BoxFit.cover, semanticLabel: brandName)))));
}
class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final pen = Paint()..color = brandPink.withValues(alpha: .30)..style = PaintingStyle.stroke;
    for (final r in [.43, .465, .495]) { canvas.drawCircle(center, size.width * r, pen); }
    pen..style = PaintingStyle.fill..color = brandPink;
    for (final angle in [.4, 2.1, 3.3, 5.4]) {
      canvas.drawCircle(center + Offset(math.cos(angle), math.sin(angle)) * (size.width * .465), 3.5, pen);
    }
  }
  @override
  bool shouldRepaint(OrbitPainter oldDelegate) => false;
}

class IslamicBackdrop extends StatelessWidget {
  const IslamicBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ColoredBox(color: brandIvory, child: Stack(children: [Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: ArchPainter()))), child]));
}
class ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()..color = brandPink.withValues(alpha: .08)..style = PaintingStyle.stroke..strokeWidth = 24;
    for (final x in [-size.width * .22, size.width * .78]) {
      final w = size.width * .46;
      final y = size.height * .1;
      final arch = Path()..moveTo(x, size.height * .74)..lineTo(x, y + w)..quadraticBezierTo(x, y + w * .4, x + w / 2, y)..quadraticBezierTo(x + w, y + w * .4, x + w, y + w)..lineTo(x + w, size.height * .74);
      canvas.drawPath(arch, pen);
    }
    pen..style = PaintingStyle.fill..color = brandPurple.withValues(alpha: .035);
    for (var i = 0; i < 5; i++) {
      final x = i * size.width / 4;
      canvas.drawRect(Rect.fromLTWH(x - 20, size.height * .68, 40, 70), pen);
      canvas.drawOval(Rect.fromLTWH(x - 20, size.height * .65, 40, 40), pen);
    }
  }
  @override
  bool shouldRepaint(ArchPainter oldDelegate) => false;
}

class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: brandPurple, body: SafeArea(child: Stack(children: [
    Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: GeometryPainter()))),
    Positioned(bottom: 28, left: 0, right: 0, child: Icon(Icons.mosque_outlined, size: 210, color: brandPink.withValues(alpha: .13))),
    const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [LogoMedallion(size: 280), SizedBox(height: 32), Text('رحلة علمية مباركة', style: TextStyle(color: Colors.white70, fontSize: 16)), SizedBox(height: 24), SizedBox(width: 100, child: LinearProgressIndicator(minHeight: 3))])),
  ])));
}
