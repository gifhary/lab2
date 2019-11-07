import 'package:flutter/material.dart';

final ThemeData appThemeData = new ThemeData(
  brightness: Brightness.dark,
  primaryColor: CompanyColors.orange[900],
  primaryColorDark: CompanyColors.black[900],
  accentColor: CompanyColors.white[900],
);

class CompanyColors {
  CompanyColors._();
  static const Map<int, Color> orange = const <int, Color>{
    50: Color.fromRGBO(255, 140, 0, .1),
    100: Color.fromRGBO(255, 140, 0, .2),
    200: Color.fromRGBO(255, 140, 0, .3),
    300: Color.fromRGBO(255, 140, 0, .4),
    400: Color.fromRGBO(255, 140, 0, .5),
    500: Color.fromRGBO(255, 140, 0, .6),
    600: Color.fromRGBO(255, 140, 0, .7),
    700: Color.fromRGBO(255, 140, 0, .8),
    800: Color.fromRGBO(255, 140, 0, .9),
    900: Color.fromRGBO(255, 140, 0, 1)
  };

  static const Map<int, Color> white = const <int, Color>{
    50: Color.fromRGBO(255, 255, 255, .1),
    100: Color.fromRGBO(255, 255, 255, .2),
    200: Color.fromRGBO(255, 255, 255, .3),
    300: Color.fromRGBO(255, 255, 255, .4),
    400: Color.fromRGBO(255, 255, 255, .5),
    500: Color.fromRGBO(255, 255, 255, .6),
    600: Color.fromRGBO(255, 255, 255, .7),
    700: Color.fromRGBO(255, 255, 255, .8),
    800: Color.fromRGBO(255, 255, 255, .9),
    900: Color.fromRGBO(255, 255, 255, 1)
  };

  static const Map<int, Color> black = const <int, Color>{
    50: Color.fromRGBO(0, 0, 0, .1),
    100: Color.fromRGBO(0, 0, 0, .2),
    200: Color.fromRGBO(0, 0, 0, .3),
    300: Color.fromRGBO(0, 0, 0, .4),
    400: Color.fromRGBO(0, 0, 0, .5),
    500: Color.fromRGBO(0, 0, 0, .6),
    600: Color.fromRGBO(0, 0, 0, .7),
    700: Color.fromRGBO(0, 0, 0, .8),
    800: Color.fromRGBO(0, 0, 0, .9),
    900: Color.fromRGBO(0, 0, 0, 1)
  };
}
