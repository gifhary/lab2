import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'home.dart';
import 'theme/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

void main() => runApp(SplashScreen());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
            brightness: brightness,
            accentColor: Theme.darkThemeData.accentColor,
            toggleableActiveColor: Theme.darkThemeData.toggleableActiveColor),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'asset/img/logo.png',
                      scale: 4,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new ProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {

            checkPref().then((onValue) {
              print("logged in ? : " + onValue.toString());

              if (onValue) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()));
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()));
              }
            });
          }
        });
      });
    controller.repeat();
  }

  //if user is in preferences, automaticaly moved to home page
  Future<bool> checkPref() async {
    print('check preferences');
    bool result = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('email');
    if (savedEmail != null) {
      print('saved email : ' + savedEmail);
      
      result = true;
    }
    return result;
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      width: 200,
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.black,
        valueColor:
            new AlwaysStoppedAnimation<Color>(Theme.darkThemeData.primaryColor),
      ),
    ));
  }
}
