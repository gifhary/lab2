import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/user.dart';
 
void main() => runApp(ProfilePage());
 
class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({Key key, this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
   return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Text(widget.user.name)
          ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}