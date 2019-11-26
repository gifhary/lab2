import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/job.dart';
import 'package:my_pickup/jobDetail.dart';
import 'package:my_pickup/user.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyJobPage());

class MyJobPage extends StatefulWidget {
  final User user;

  MyJobPage({Key key, this.user});

  @override
  _MyJobPageState createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  List<Job> job;

  @override
  void initState() {
    super.initState();

    _checkPref().then((email) {
      if (email != null) {
        //if user logged in then load jon using user email
        _loadJob(email);
      } else {
        //else load job using device id
        _getDeviceId().then((deviceId) {
          _loadJob(deviceId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: ListView.builder(
          itemBuilder: (context, position) {
            return new GestureDetector(
              onTap: () => _openDetail(job[position]),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                    child: Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          //TODO display job image from retrieved path from DB
                            "https://miro.medium.com/max/640/1*rIL0njh-OExpKt4WS55LMQ.jpeg"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            //TODO display job name and price
                            Text("JobName", style: TextStyle(fontSize: 16)),
                            SizedBox(
                              width: 50,
                            ),
                            Text("JobPrice : RM",
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            );
          },
          itemCount: 5,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _addJob,
        ),
      ),
    );
  }

  _openDetail(Job job) {
    //open detail page with job object (obvious stuff :D)
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => JobDetailPage(job: job)));
  }

  void _addJob() {
    //TODO load job from db
  }

  void _loadJob(String email) {
    //TODO load job with user email from db
  }

  static Future<String> _getDeviceId() async {
    //get device id as an identifier if user want to create job without an account
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

    return identifier;
  }

  //use preferences to get email instead of widget.user.email
  //getting email from previous class take some time to load from
  //database and can cause error in this class or user has logged in
  //but this class consider user as not logged in since the email
  //come late
  Future<String> _checkPref() async {
    print('check preferences');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('email');
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}
