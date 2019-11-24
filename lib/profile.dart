import 'package:flutter/material.dart';
 
void main() => runApp(ProfilePage());
 
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: Center(
          child: Container(
            child: Text('Memeq'),
          ),
        ),
      ),
    );
  }
}