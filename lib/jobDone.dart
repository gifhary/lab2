import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/slidingRoute.dart';
import 'package:my_pickup/user.dart';
import 'theme/theme.dart' as Theme;
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

import 'job.dart';
import 'jobDetail.dart';

void main() => runApp(JobDonePage());

class JobDonePage extends StatefulWidget {
  final Function() notifyParent;
  final User user;

  JobDonePage({Key key, this.user, this.notifyParent});

  @override
  _JobDonePageState createState() => _JobDonePageState();
}

class _JobDonePageState extends State<JobDonePage> {
  List<Job> job = [];
  String _defaultImg = 'asset/img/profile.png';
  String _avatarUrl = "";
  String _email = "";

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      //if user logged in then load job using user email
      print("Load job with email : " + widget.user.email);
      _loadJob(widget.user.email);
      _email = widget.user.email;
      _avatarUrl =
          "http://pickupandlaundry.com/my_pickup/gifhary/profile/$_email.jpg";
    } else {
      //else load job using device id
      _getDeviceId().then((deviceId) {
        _loadJob(deviceId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: job.length < 1
          ? Column(children: <Widget>[Text("Nothing to see here")])
          : ListView.builder(
              itemCount: job.length,
              itemBuilder: (context, position) {
                return new GestureDetector(
                  onTap: () => _openDetail(job[position]),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.darkThemeData.primaryColor,
                                    width: 10,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CircleAvatar(
                                      radius: 40,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          imageUrl: _avatarUrl,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(_defaultImg),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(job[position].jobName,
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold)),
                                        Text("RM " + job[position].jobPrice,
                                            style: TextStyle(fontSize: 18)),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                            timeago.format(_jobTime(
                                                job[position].jobDate)),
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        )),
                  ),
                );
              },
            ),
    );
  }

  void _loadJob(String email) {
    String url =
        'http://pickupandlaundry.com/my_pickup/gifhary/load_job_done.php';

    //not using progress dialog
    //there is one weird bug, the dialog still there after login
    //even with pr.dismiss(), still wont dissapear
    http.post(url, body: {"email": email}).then((res) {
      if (res.body != "nodata") {
        var jobData = json.decode(res.body);

        List rawJobData = jobData["jobs"];
        print("Raw Data : " + rawJobData.toString());
        _convertToJob(rawJobData);
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _convertToJob(List list) {
    setState(() {
      for (var jobData in list) {
        job.add(new Job(
            jobId: jobData['job_id'],
            jobName: jobData['job_name'],
            jobPrice: jobData['job_price'],
            jobDesc: jobData['job_desc'],
            jobLocation: jobData['job_location'],
            jobDestination: jobData['job_destination'],
            jobOwner: jobData['job_owner'],
            jobDate: jobData['job_date'],
            driverEmail: jobData['driver_email']));
      }
      print("first job name : " + job[0].jobName);
      _updateCount();
    });
  }

  void _updateCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pickupDoneCount", job.length.toString());
    widget.notifyParent();
  }

  DateTime _jobTime(String time) {
    DateTime dateTime = new DateFormat("dd/MM/yyyy HH:mm:ss").parse(time);
    return dateTime;
  }

  _openDetail(Job job) {
    //open detail page with job object (obvious stuff :D)
    Navigator.push(
        context,
        SlideRightRoute(
            page: JobDetailPage(job: job, delete: _removeListValue)));
  }

  void _removeListValue(String id) {
    setState(() {
      job.removeWhere((item) => item.jobId == id);
    });
    _updateCount();
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
}
