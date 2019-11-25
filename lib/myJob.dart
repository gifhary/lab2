import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/user.dart';

void main() => runApp(MyJobPage());

class MyJobPage extends StatefulWidget {
  final User user;

  MyJobPage({Key key, this.user});
  
  @override
  _MyJobPageState createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Text('MyJob'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _addJob,
        ),
      ),
    );
  }

  void _addJob() {
    print(widget.user.name);
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}
