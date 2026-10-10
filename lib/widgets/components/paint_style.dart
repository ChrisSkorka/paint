import 'package:flutter/material.dart';

abstract final class PaintStyle {
  static const barBackground = Color(0xFFF8F8F8);
  static const canvasAreaBackground = Color(0xFFEEEEEE);
  static const iconColor = Color(0xFF444444);
  static const titleColor = Color(0xB3000000);
  static const separatorColor = Color(0x1A000000);
  static const hoverBackground = Color(0x08000000);
  static const hoverBorder = Color(0x1A000000);
  static const inputBorder = Color(0x4D000000);
  static const inputFocusBorder = Color(0x80000000);
  static const dialogBorder = Color(0x1A000000);
  static const chessLight = Color(0xFFFFFFFF);
  static const chessDark = Color(0xFFDDDDDD);

  static const primaryColor = Color(0xFFCD5C5C);
  static const penColor = Color(0xFFFF8C00);
  static const eraserColor = Color(0xFFCD5C5C);
  static const fillColor = Color(0xFF8A2BE2);
  static const colorPickerColor = Color(0xFF1E90FF);
  static const saveColor = Color(0xFF00BFFF);

  static const radius = BorderRadius.all(Radius.circular(5));
  static const fontFamily = 'Arial';
  static const ribbonContentHeight = 80.0;
  static const swatchSize = 15.0;
  static const chessCellSize = 8.0;
  static const hoverDuration = Duration(milliseconds: 100);
  static const sidePanelWidth = 200.0;

  static const titleStyle = TextStyle(
    color: titleColor,
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  static const barShadow = [BoxShadow(color: Color(0x1A000000), blurRadius: 5)];
  static const faintShadow = [
    BoxShadow(color: Color(0x80000000), blurRadius: 3, spreadRadius: -2),
  ];
  static const focusShadow = [
    BoxShadow(color: Color(0xCC000000), blurRadius: 3, spreadRadius: -1),
  ];

  static ThemeData theme() {
    return ThemeData(
      fontFamily: fontFamily,
      scaffoldBackgroundColor: canvasAreaBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: barBackground,
      ),
      iconTheme: const IconThemeData(color: iconColor, size: 16),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: iconColor, fontSize: 13),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: inputFocusBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFFCD5C5C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Color(0xFFCD5C5C)),
        ),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          elevation: WidgetStatePropertyAll(2),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: dialogBorder),
            ),
          ),
        ),
      ),
    );
  }
}
