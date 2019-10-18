import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0x3b3b3b)),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(40, 40, 40, 1),
          resizeToAvoidBottomPadding: false,
          body: new Container(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'asset/img/logo.png',
                  scale: 3,
                ),
                TextField(
                    controller: _emcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)))),
                TextField(
                  controller: _passcontroller,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.lock, color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white))),
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: 300,
                  height: 50,
                  child: Text(
                    'Login',
                    style: new TextStyle(fontSize: 20.0),
                  ),
                  color: Color.fromRGBO(255, 140, 0, 1),
                  textColor: Colors.black,
                  elevation: 15,
                  onPressed: _onLogin,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: Checkbox(
                          checkColor: Colors.black,
                          activeColor: Color.fromRGBO(255, 140, 0, 1),                            
                          value: _isChecked,
                          onChanged: (bool value) {
                            _onChange(value);
                          },
                        )),
                    Text('Remember Me',
                        style: TextStyle(fontSize: 16, color: Colors.white))
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                    onTap: _onRegister,
                    child: Text('Register New Account',
                        style: TextStyle(fontSize: 16, color: Colors.white))),
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                    onTap: _onForgot,
                    child:
                        Text('Forgot Account', style: TextStyle(fontSize: 16, color: Colors.white))),
              ],
            ),
          ),
        ));
  }

  void _onLogin() {
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    Toast.show("The button is working", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //TODO handle login button
  }

  void _onRegister() {
    print('onRegister');
    //Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    //TODO handle register button
    Toast.show("The button is working", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
