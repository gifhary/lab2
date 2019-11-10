import 'package:flutter/material.dart';

ThemeData darkThemeData = new ThemeData(
  primaryColor: CompanyColors.orange[900],
  primaryColorDark: Colors.black,
  accentColor: CompanyColors.orange[900],
  toggleableActiveColor: CompanyColors.orange[900],
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
}
