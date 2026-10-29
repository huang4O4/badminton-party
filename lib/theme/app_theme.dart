import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF00A651);
  static const greenDark = Color(0xFF008F45);
  static const ink = Color(0xFF1B1B1B);
  static const muted = Color(0xFF8A8F98);
  static const chip = Color(0xFFF3F4F6);
  static const page = Color(0xFFF7F8FA);
  static const stroke = Color(0xFFE7E9EE);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      brightness: Brightness.light,
    ),
    fontFamily: 'NotoSansThai',
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerColor: AppColors.stroke,
  );
}
