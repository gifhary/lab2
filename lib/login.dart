import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/home.dart';
import 'package:my_pickup/register.dart';
import 'package:my_pickup/resetPassword.dart';
import 'package:my_pickup/user.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

import 'theme/theme.dart' as Theme;

String urlLogin = 'http://pickupandlaundry.com/my_pickup/gifhary/login.php';
String urlSecurityCodeForResetPass =
    'http://pickupandlaundry.com/my_pickup/gifhary/security_code.php';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: SingleChildScrollView(
            child: new Container(
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
                      child: Text('Forgot Account',
                          style: TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
        ));
  }

  void _onLogin() {
    _email = _emcontroller.text;
    _password = _passcontroller.text;

    if (_isEmailValid(_email) && (_password.length > 4)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login in");
      pr.show();
      http.post(urlLogin, body: {
        "email": _email,
        "password": _password,
      }).then((res) {
        print("status code : " + res.statusCode.toString());
        if (res.body != "failed") {
          pr.dismiss();
          //save login credential
          savePref("email", _email);
          savePref("password", _password);

          Toast.show("success", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

          var userData = json.decode(res.body);
          print("user data : " + userData.toString());

          User user = new User(
              name: userData['user_name'],
              email: userData['user_email'],
              phone: userData['user_phone']);

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomePage(user: user)));
        } else {
          pr.dismiss();
          Toast.show(res.body, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {}
  }

  void savePref(String key, String value) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _onRegister() {
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  void _onForgot() {
    _email = _emcontroller.text;

    if (_isEmailValid(_email)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Sending Email");
      pr.show();
      http.post(urlSecurityCodeForResetPass, body: {
        "email": _email,
      }).then((res) {
        print("secure code : " + res.body);
        if (res.body == "error") {
          pr.dismiss();

          Toast.show('error', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          pr.dismiss();

          _saveEmailForPassReset(_email);
          _saveSecureCode(res.body); //save secure code for password reset

          Toast.show('Security code sent to your email', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ResetPassword()));
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {
      Toast.show('Invalid Email', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveEmailForPassReset(String email) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('resetPassEmail', email);
  }

  void _saveSecureCode(String code) async {
    print('saving preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('secureCode', code);
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}
