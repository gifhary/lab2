import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/register.dart';
import 'package:toast/toast.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/theme.dart' as Theme;

String logo = 'asset/img/logo.png';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emcontroller = TextEditingController();
  String _email = "";
  final TextEditingController _passcontroller = TextEditingController();
  String _password = "";
  bool _isChecked = false;
  bool _isSwitched = false;

  static const String _themePreferenceKey = 'isDark';

  @override
  void initState() {
    loadpref();
    print('Init: $_email');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new Container(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  logo,
                  scale: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: _emcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    )),
                TextField(
                  controller: _passcontroller,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: 300,
                  height: 50,
                  child: Text(
                    'Login',
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Theme.darkThemeData.primaryColorDark),
                  ),
                  color: Theme.darkThemeData.primaryColor,
                  elevation: 15,
                  onPressed: _onLogin,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.brightness_medium,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Dark Theme', style: TextStyle(fontSize: 16)),
                    SizedBox(
                      width: 25,
                    ),
                    Switch(
                      value: _isSwitched,
                      onChanged: (bool value) {
                        _onThemeChanged(value);
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      checkColor: Theme.darkThemeData.primaryColorDark,
                      activeColor: Theme.darkThemeData.primaryColor,
                      value: _isChecked,
                      onChanged: (bool value) {
                        _onChange(value);
                      },
                    ),
                    Text('Remember Me', style: TextStyle(fontSize: 16))
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                    onTap: _onRegister,
                    child: Text('Register New Account',
                        style: TextStyle(fontSize: 16))),
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                    onTap: _onForgot,
                    child:
                        Text('Forgot Account', style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ));
  }

  void loadpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_themePreferenceKey) != null) {
      _isSwitched = (prefs.getBool(_themePreferenceKey));
      setState(() {});
      print('ThemePrefs : DarkMode : ' +
          prefs.getBool(_themePreferenceKey).toString());
    }
  }

  void _onThemeChanged(bool value) {
    if (value) {
      DynamicTheme.of(context).setBrightness(Brightness.dark);
      _isSwitched = true;
    } else {
      DynamicTheme.of(context).setBrightness(Brightness.light);
      _isSwitched = false;
    }
  }

  void _onLogin() {
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    //TODO handle login button
  }

  void _onRegister() {
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  void _onForgot() {
    //TODO handle forgot account button
    Toast.show("The button is working", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      //TODO handle remember me check box
    });
  }
}

Future<bool> _onBackPressAppBar() async {
  SystemNavigator.pop();
  print('Backpress');
  return Future.value(false);
}
