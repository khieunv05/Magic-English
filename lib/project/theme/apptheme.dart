import 'package:flutter/material.dart';
class AppTheme{
  static const primaryColor =  Color.fromARGB(255, 58, 148, 231);
  static const secondaryColor = Color.fromARGB(255, 247, 252, 255);
  static const blackColor = Color.fromARGB(255, 37, 37, 38);
  static final textFieldBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: const BorderSide(
      color: primaryColor,
      width: 2
  ));
  static const avartarCircleRadiusLogin =40.0;
  static const singleChildScrollViewHeight = 80.0;
  static final ThemeData appTheme = ThemeData(
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: blackColor,),
      bodyLarge: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: blackColor),
      bodyMedium: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: blackColor,height: 2,
      wordSpacing: 1.5),
      bodySmall: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: blackColor,),
      labelLarge: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.white),
      headlineLarge: TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 51, 45, 161),
      fontFamily: 'Aubrey')
    ),
    scaffoldBackgroundColor: secondaryColor,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28)
        ),
        padding: const EdgeInsets.all(16),
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
          padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,

        )
      )
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(20),
        iconSize: 28,
      )
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: blackColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,

      ),
      iconTheme: IconThemeData(
        size: 24,
        color: blackColor
      )
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: blackColor.withAlpha(100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28)
      )
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: blackColor),
      enabledBorder: textFieldBorder,
      focusedBorder: textFieldBorder,
      border: textFieldBorder,
      filled: true,
      fillColor: Colors.white,
    ),

    iconTheme: const IconThemeData(
      size: 28,
      color: blackColor
    )

  );

}