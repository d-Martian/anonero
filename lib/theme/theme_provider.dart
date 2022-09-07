import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffFF6600),
  onPrimary: Color(0xff000000),
  primaryContainer: Color(0xff297ea0),
  onPrimaryContainer: Color(0xffd9edf5),
  secondary: Color(0xffa1e9df),
  onSecondary: Color(0xff030303),
  secondaryContainer: Color(0xff005049),
  onSecondaryContainer: Color(0xffd0e3e1),
  tertiary: Color(0xffa0e5e5),
  onTertiary: Color(0xff181e1e),
  tertiaryContainer: Color(0xff004f50),
  onTertiaryContainer: Color(0xffd0e2e3),
  error: Color(0xffcf6679),
  onError: Color(0xff1e1214),
  errorContainer: Color(0xffb1384e),
  onErrorContainer: Color(0xfff9dde2),
  outline: Color(0xff959999),
  background: Color(0xff000000),
  onBackground: Color(0xffe3e4e4),
  surface: Color(0xff131516),
  onSurface: Color(0xfff1f1f1),
  surfaceVariant: Color(0xff15191b),
  onSurfaceVariant: Color(0xffe3e3e4),
  inverseSurface: Color(0xfffafcfd),
  onInverseSurface: Color(0xff0e0e0e),
  inversePrimary: Color(0xff355967),
  shadow: Color(0xff000000),
);

class ThemeProvider extends ChangeNotifier {
  ThemeData getTheme() {
    return ThemeData(
        colorScheme: colorScheme,
        primaryColor: colorScheme.primary,
        fontFamily: GoogleFonts.robotoMono().fontFamily,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith((states) {
            return const EdgeInsets.symmetric(vertical: 14, horizontal: 34);
          }),
          shape: MaterialStateProperty.resolveWith((states) {
            if(states.contains(MaterialState.pressed)){
              return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
            }
            return RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
          }),
        )),
        buttonTheme: ButtonThemeData(
            padding: const EdgeInsets.all(12), colorScheme: colorScheme.copyWith(primary: Colors.white,background: Colors.white)),
        useMaterial3: false);
  }
}
