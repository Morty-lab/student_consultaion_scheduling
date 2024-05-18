import 'package:facultyconsultationscheduling/themes/colors.dart';
import 'package:flutter/material.dart';

final ColorScheme kColorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

var appTheme = ThemeData(
  useMaterial3: false,
  fontFamily: 'Satoshi',
  colorScheme: kColorScheme,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Satoshi'),
    bodyMedium: TextStyle(fontFamily: 'Satoshi'),
    titleMedium: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontFamily: 'Satoshi', fontWeight: FontWeight.w500),
    displayLarge: TextStyle(fontFamily: 'Satoshi'),
    displayMedium: TextStyle(fontFamily: 'Satoshi'),
    displaySmall: TextStyle(fontFamily: 'Satoshi'),
    headlineMedium: TextStyle(fontFamily: 'Satoshi'),
    headlineSmall: TextStyle(fontFamily: 'Satoshi'),
    headlineLarge: TextStyle(fontFamily: 'Satoshi'),
    bodySmall: TextStyle(fontFamily: 'Satoshi'),
    labelLarge: TextStyle(fontFamily: 'Satoshi', fontSize: 16),
    labelMedium: TextStyle(fontFamily: 'Satoshi', fontSize: 16),
    labelSmall: TextStyle(fontFamily: 'Satoshi', fontSize: 13.5),
  ),
);
