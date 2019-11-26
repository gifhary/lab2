import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/user.dart';
 
void main() => runApp(JobDonePage());
 
class JobDonePage extends StatefulWidget {
  final User user;

  JobDonePage({Key key, this.user});

  @override
  _JobDonePageState createState() => _JobDonePageState();
}

class _JobDonePageState extends State<JobDonePage> {
  @override
  Widget build(BuildContext context) {
   return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Text("Job done"),
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