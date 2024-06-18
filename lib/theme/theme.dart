// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xff1E5541),
  fontFamily: 'Play',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(
        Color(0xffA1FF80),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(color: Color(0xff1E5541), fontWeight: FontWeight.bold),
      ),
    ),
  ),
);
