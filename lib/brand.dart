import 'package:flutter/material.dart';

const brandName = 'المحجة البيضاء';
const brandPurple = Color(0xff2b274b);
const brandPink = Color(0xffddaeb5);
const brandIvory = Color(0xfffaf8f5);

ThemeData academyTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandPurple).copyWith(
    primary: brandPurple, onPrimary: Colors.white,
    secondary: brandPink, onSecondary: brandPurple,
    surface: brandIvory, onSurface: brandPurple,
    secondaryContainer: const Color(0xfff5e1e4),
  );
  return ThemeData(
    useMaterial3: true, colorScheme: scheme,
    scaffoldBackgroundColor: brandIvory,
    appBarTheme: const AppBarTheme(backgroundColor: brandIvory, foregroundColor: brandPurple, centerTitle: false, elevation: 0),
    cardTheme: CardTheme(color: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0.5, margin: const EdgeInsets.symmetric(vertical: 7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xffe9e3e6)))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xffddd6df)))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: Color(0xfff5e1e4), elevation: 0, height: 76),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: brandPink, linearTrackColor: Color(0xffe9e3ee), borderRadius: BorderRadius.all(Radius.circular(10))),
  );
}

/// Display the supplied artwork directly, centering its logo without altering it.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 320});
  final double width;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.asset('assets/brand/logo.jpg', width: width, height: width / 1.85,
      fit: BoxFit.cover, alignment: const Alignment(0, 0.05), semanticLabel: '$brandName للعلوم الشرعية'),
  );
}

class BrandHeading extends StatelessWidget {
  const BrandHeading({super.key});
  @override
  Widget build(BuildContext context) => const Row(children: [
    BrandLogo(width: 48), SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(brandName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      Text('للعلوم الشرعية', style: TextStyle(fontSize: 11)),
    ])),
  ]);
}

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key, required this.child, this.padding = const EdgeInsets.all(26)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [brandPurple, Color(0xff42395e)]), borderRadius: BorderRadius.circular(24)),
    child: child,
  );
}
