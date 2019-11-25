import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/login.dart';
import 'package:my_pickup/myJob.dart';
import 'package:my_pickup/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:http/http.dart' as http;

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _themePreferenceKey = 'isDark';
  bool _isSwitched = false;
  String _userName = "";
  String _email = "";
  bool _hasLoggedIn = false;

  String _lastNaviagion = "Log in";

  List<Widget> pages;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      MyJobPage(),
      ProfilePage(),
    ];

    _loadThemePref();

    _checkPref().then((onValue) {
      if (onValue != null) {
        _email = onValue;
        _hasLoggedIn = true;
        _lastNaviagion = "Log out";

        _loadUserData(onValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pickup"),
      ),
      body: pages[pageIndex],
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  "A",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.brightness_medium),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Dark Theme', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              trailing: Switch(
                value: _isSwitched,
                onChanged: (bool value) {
                  _onThemeChanged(value);
                },
              ),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.event),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("My Job", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
              selected: pageIndex == 0,
              onTap: () => onSelectItem(0),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.person),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("Profile", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
              selected: pageIndex == 1,
              onTap: () => onSelectItem(1),
            ),
            Divider(),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.exit_to_app),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(_lastNaviagion, style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
              onTap: () => outOrIn(_hasLoggedIn),
            ),
          ],
        ),
      ),
    );
  }

  onSelectItem(int index) {
    setState(() {
      pageIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _loadUserData(String email) {
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/get_user.php';

    http.post(url, body: {
      "email": email,
    }).then((res) {
      print("user name : " + res.body);

      setState(() {
        _userName = res.body;
      });
    }).catchError((err) {
      print(err);
    });
  }

  Future<String> _checkPref() async {
    print('check preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('email');
  }

  void _loadThemePref() async {
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

  outOrIn(bool value){
    if(value){
      _logOut();
    }
    else{
      _logIn();
    }
  }

  void _logIn(){
      Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _logOut() async {
    Navigator.of(context).pop();
    //set page to myJob page
    pageIndex = 0;
    _hasLoggedIn = false;
    _lastNaviagion = "Log in";
    _email = "";
    _userName = "You are not logged in";

    bool theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = prefs.getBool(_themePreferenceKey); //get theme value
    prefs.clear(); //clear preferences
    prefs.setBool(_themePreferenceKey, theme); //put back theme in preferences
    setState(() {});
  }
}
