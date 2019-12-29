import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/jobDone.dart';
import 'package:my_pickup/login.dart';
import 'package:my_pickup/myJob.dart';
import 'package:my_pickup/profile.dart';
import 'package:my_pickup/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  static String apiKey = "NOT A CHANCE";

  final User user;
  HomePage({Key key, this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _themePreferenceKey = 'isDark';
  bool _isSwitched = false;
  User updateAbleUser;

  String _userName = "You are not logged in";
  String _email = "";
  bool _hasLoggedIn = false;
  String _profilePath = 'asset/img/profile.png';
  String _avatarUrl = "";

  String _lastNaviagion = "Log in";

  List<Widget> pages;

  int pageIndex = 0;

  String myPickupCount = "";
  String pickupDoneCount = "";

  @override
  void initState() {
    super.initState();
    updateAbleUser = widget.user;

    _loadThemePref();
    _updatePages();
    _loadPickupCount();
    _loadPickupDoneCount();

    if (widget.user != null) {
      _email = updateAbleUser.email;
      _userName = updateAbleUser.name;
      _hasLoggedIn = true;
      _lastNaviagion = "Log out";
      _avatarUrl =
          "http://pickupandlaundry.com/my_pickup/gifhary/profile/$_email.jpg";
    }
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl: _avatarUrl,
                    errorWidget: (context, url, error) =>
                        Image.asset(_profilePath),
                  ),
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
                    child: Text("My Pickup", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
              trailing: Text(myPickupCount),
              selected: pageIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.check),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("Pickup Done", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
              trailing: Text(pickupDoneCount),
              selected: pageIndex == 1,
              onTap: () => _onSelectItem(1),
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
              selected: pageIndex == 2,
              onTap: () => _onSelectItem(2),
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

  void _updatePages() {
    pages = [
      new MyJobPage(user: updateAbleUser, notifyParent: _loadPickupCount),
      new JobDonePage(user: updateAbleUser, notifyParent: _loadPickupDoneCount),
      new ProfilePage(user: updateAbleUser, notifyParent: _updateUser),
    ];
  }

  void _updateUser(String credit) {
    setState(() {
      updateAbleUser.credit = credit;
    });
  }

  _onSelectItem(int index) {
    if (!_hasLoggedIn && index == 2) {
      Toast.show('Login to view profile', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() {
        pageIndex = index;
      });
    }

    Navigator.of(context).pop();
  }

  void _loadThemePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_themePreferenceKey) != null) {
      _isSwitched = prefs.getBool(_themePreferenceKey);
      setState(() {});
      print('ThemePrefs : DarkMode : ' +
          prefs.getBool(_themePreferenceKey).toString());
    }
  }

  void _loadPickupCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String count = prefs.getString("myPickupCount");
    setState(() {
      if (count != null) {
        myPickupCount = count;
      }
    });
  }

  void _loadPickupDoneCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String count = prefs.getString("pickupDoneCount");
    setState(() {
      if (count != null) {
        pickupDoneCount = count;
      }
    });
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

  outOrIn(bool value) {
    if (value) {
      _logOut();
    } else {
      _logIn();
    }
  }

  void _logIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _logOut() async {
    Navigator.of(context).pop();
    //set page to myJob page
    _hasLoggedIn = false;
    _lastNaviagion = "Log in";
    _email = "";
    _userName = "You are not logged in";

    bool theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = prefs.getBool(_themePreferenceKey); //get theme value
    prefs.clear(); //clear preferences
    prefs.setBool(_themePreferenceKey, theme); //put back theme in preferences

    //back to home page to refresh MyJobPage
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage(user: null)));
  }
}
