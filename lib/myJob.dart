import 'package:flutter/material.dart';
 
void main() => runApp(MyJobPage());
 
class MyJobPage extends StatefulWidget {
  @override
  _MyJobPageState createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: Center(
          child: Container(
            child: Text('Kuntul'),
          ),
        ),
      ),
    );
  }
}