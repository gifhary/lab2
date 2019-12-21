import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/job.dart';
import 'package:my_pickup/jobDetail.dart';
import 'package:my_pickup/slidingRoute.dart';
import 'package:my_pickup/user.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'theme/theme.dart' as Theme;
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:place_picker/place_picker.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';

void main() => runApp(MyJobPage());

class MyJobPage extends StatefulWidget {
  final Function() notifyParent;
  final User user;

  MyJobPage({Key key, this.user, this.notifyParent});

  @override
  _MyJobPageState createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  List<Job> job = [];
  String _defaultImg = 'asset/img/profile.png';
  String _avatarUrl = "";
  String _email = "";

  final String apiKey = "SECRET KEY";

  final TextEditingController _jobNameCon = TextEditingController();
  final TextEditingController _priceCon = TextEditingController();
  final TextEditingController _descCon = TextEditingController();
  final TextEditingController _pickupCon = TextEditingController();
  final TextEditingController _destiCon = TextEditingController();

  String _pickupLocation;
  String _destinationLocation;

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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40.0),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        imageUrl: _avatarUrl,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(_defaultImg),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
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
                                          timeago.format(
                                              _jobTime(job[position].jobDate)),
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ],
                              )),
                        )),
                  ),
                );
              },
              itemCount: job.length,
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addJobDialog,
      ),
    );
  }

  DateTime _jobTime(String time) {
    DateTime dateTime = new DateFormat("dd/MM/yyyy HH:mm:ss").parse(time);
    return dateTime;
  }

  _openDetail(Job job) {
    //open detail page with job object (obvious stuff :D)
    Navigator.push(context, SlideRightRoute(page: JobDetailPage(job: job)));
  }

  Future<void> _addJobDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order a Ride'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                    controller: _jobNameCon,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Job name',
                      icon: Icon(Icons.directions_car),
                    )),
                TextField(
                    controller: _priceCon,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      icon: Icon(Icons.attach_money),
                    )),
                TextField(
                    controller: _descCon,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      icon: Icon(Icons.description),
                    )),
                TextField(
                    onTap: _setPickupPoint,
                    focusNode: AlwaysDisabledFocusNode(),
                    controller: _pickupCon,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Pickup point',
                      icon: Icon(Icons.location_searching),
                    )),
                TextField(
                    onTap: _setDestination,
                    focusNode: AlwaysDisabledFocusNode(),
                    controller: _destiCon,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "I'm going to...",
                      icon: Icon(Icons.location_on),
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: _cancel,
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: _prepareJob,
            ),
          ],
        );
      },
    );
  }

  void _prepareJob() async {
    String jobName = _jobNameCon.text;
    String price = _priceCon.text;
    String description = _descCon.text;
    String location = _pickupLocation;
    String destination = _destinationLocation;

    if (jobName.isEmpty ||
        price.isEmpty ||
        location.isEmpty ||
        destination.isEmpty) {
      Toast.show("Please complete the field", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      if (widget.user != null) {
        _uploadJob(widget.user.email, jobName, price, description, location,
            destination);
      } else {
        _getDeviceId().then((deviceId) {
          _uploadJob(
              deviceId, jobName, price, description, location, destination);
        });
      }
    }
  }

  void _uploadJob(
      String email, jobName, price, description, location, destination) {
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/upload_job.php';

    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Requesting pickup");
    pr.show();

    http.post(url, body: {
      "job_name": jobName,
      "job_price": price,
      "job_desc": description,
      "job_location": location,
      "job_destination": destination,
      "email": email,
    }).then((res) {
      print(res.statusCode);
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      pr.dismiss();

      if (res.body == "success") {
        _loadJob(email);
        _cancel();
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _cancel() {
    setState(() {
      _jobNameCon.text = "";
      _priceCon.text = "";
      _descCon.text = "";
      _pickupCon.text = "";
      _destiCon.text = "";

      _pickupLocation = null;
      _destinationLocation = null;
    });

    Navigator.of(context).pop();
  }

  void _setPickupPoint() async {
    LocationResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PlacePicker(apiKey)));
    if (result != null) {
      _pickupCon.text = result.name;
      _pickupLocation = result.latLng.latitude.toString() +
          "," +
          result.latLng.longitude.toString();
    }
  }

  void _setDestination() async {
    LocationResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PlacePicker(apiKey)));
    if (result != null) {
      _destiCon.text = result.name;
      _destinationLocation = result.latLng.latitude.toString() +
          "," +
          result.latLng.longitude.toString();
    }
  }

  void _loadJob(String email) {
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/load_jobs.php';

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
      job.clear();

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
      _setStringPrefs(job.length.toString());
    });
  }

  void _setStringPrefs(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myPickupCount", value);
    widget.notifyParent();
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
