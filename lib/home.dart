import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme.dart' as Theme;

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: 300,
                  height: 50,
                  child: Text('Log Out',
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: Theme.darkThemeData.primaryColorDark)),
                  color: Theme.darkThemeData.primaryColor,
                  elevation: 15,
                  onPressed: _logOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _logOut() async {
    print('Log out');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}
