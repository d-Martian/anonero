import 'package:anon_wallet/screens/landing_screen.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeProvider().getTheme(),
      home: const LandingScreen(),
    );
  }
}
