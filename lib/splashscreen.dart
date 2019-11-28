import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:my_pickup/user.dart';
import 'home.dart';
import 'theme/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(SplashScreen());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
            primaryColor: Theme.darkThemeData.primaryColor,
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
  String urlLogin = 'http://pickupandlaundry.com/my_pickup/gifhary/login.php';

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          _checkPref().then((onValue) {
            if (onValue[0] != null && onValue[1] != null) {
              _getUser(onValue[0], onValue[1]);
            } else {
              _moveToHome(null);
            }
          });
        });
      });
    controller.repeat();
  }

  void _moveToHome(User user) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomePage(user: user)));
  }

  void _getUser(String email, String password) {
    http.post(urlLogin, body: {
      "email": email,
      "password": password,
    }).then((res) {
      print("status code : " + res.statusCode.toString());
      if (res.body != "failed") {
        var userData = json.decode(res.body);
        print("user data : " + userData.toString());

        User user = new User(
            name: userData['user_name'],
            email: userData['user_email'],
            phone: userData['user_phone']);

        _moveToHome(user);
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<List> _checkPref() async {
    print('check preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    String password = prefs.getString('password');

    return [email, password];
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
