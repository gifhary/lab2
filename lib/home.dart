import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/login.dart';
import 'package:my_pickup/myJob.dart';
import 'package:my_pickup/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme.dart' as Theme;
import 'package:dynamic_theme/dynamic_theme.dart';

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _themePreferenceKey = 'isDark';
  bool _isSwitched = false;
  bool _hasLoggedIn = false;

  List<Widget> pages;

  int pageIndex = 0;

  @override
  void initState() {
    pages = [
      MyJobPage(),
      ProfilePage(),
    ];

    _loadThemePref();

    _checkPref().then((onValue) {
      _hasLoggedIn = onValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Pickup"),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Ashish Rawat"),
                accountEmail: Text("ashishrawat2911@gmail.com"),
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
                onTap: _onSelectItem(0),
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
                onTap: _onSelectItem(1),
              ),
              Divider(),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text("Log out", style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
                onTap: _removePrefsExceptTheme,
              ),
            ],
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: pages[pageIndex],
      ),
    );
  }

  _onSelectItem(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  Future<bool> _checkPref() async {
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

  void _removePrefsExceptTheme() async {
    bool theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = prefs.getBool(_themePreferenceKey); //get theme value
    prefs.clear(); //clear preferences
    prefs.setBool(_themePreferenceKey, theme); //put back theme in preferences
    setState(() {});
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}
