import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pickup/job.dart';
import 'package:my_pickup/jobDetail.dart';
import 'package:my_pickup/user.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyJobPage());

class MyJobPage extends StatefulWidget {
  final User user;

  MyJobPage({Key key, this.user});

  @override
  _MyJobPageState createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  List<Job> job = [];
  File _image;

  String _assetPath = 'asset/img/camera.png';

  final TextEditingController _jobNameCon = TextEditingController();
  final TextEditingController _priceCon = TextEditingController();
  final TextEditingController _descCon = TextEditingController();

  @override
  void initState() {
    super.initState();

    _checkPref().then((email) {
      if (email != null) {
        //if user logged in then load job using user email
        print("Load job with email : " + email);
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
    return Scaffold(
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
                          "http://pickupandlaundry.com/my_pickup/gifhary/image/${job[position].jobImage}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Text(job[position].jobName,
                              style: TextStyle(fontSize: 16)),
                          SizedBox(
                            width: 50,
                          ),
                          Text("Price : RM " + job[position].jobPrice,
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
        itemCount: job.length,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addJobDialog,
      ),
    );
  }

  _openDetail(Job job) {
    //open detail page with job object (obvious stuff :D)
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => JobDetailPage(job: job)));
  }

  Future<void> _addJobDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order a Ride'),
          content: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: _takePic,
                  child: Container(
                    width: 180,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: _image == null
                              ? AssetImage(_assetPath)
                              : FileImage(_image),
                          fit: BoxFit.fill,
                        )),
                  )),
              TextField(
                  controller: _jobNameCon,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Job Name',
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
              //TODO add location picker for create new job
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: _uploadJob,
            ),
          ],
        );
      },
    );
  }

  void _uploadJob() {
    Navigator.of(context).pop();
    //TODO upload job here
  }

  void _takePic() async {
    File _cameraImage = await ImagePicker.pickImage(source: ImageSource.camera);
    if (_cameraImage != null) {
      //Avoid crash if user cancel picking image
      setState(() {
        _image = _cameraImage;
      });
    }
  }

  void _loadJob(String email) {
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/load_jobs.php';

    //not using progress dialog
    //there is one weird bug, the dialog still there after login
    //even with pr.dismiss(), still wont dissapear

    http.post(url, body: {"email": email}).then((res) {
      var jobData = json.decode(res.body);
      setState(() {
        List rawJobData = jobData["jobs"];
        print("Raw Data : " + rawJobData.toString());
        _convertToJob(rawJobData);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _convertToJob(List list) {
    for (var jobData in list) {
      job.add(new Job(
          jobId: jobData['job_id'],
          jobName: jobData['job_name'],
          jobPrice: jobData['job_price'],
          jobDesc: jobData['job_desc'],
          jobLocation: jobData['job_location'],
          jobOwner: jobData['job_owner'],
          jobDate: jobData['job_date'],
          jobImage: jobData['job_image'],
          driverEmail: jobData['driver_email']));
    }
    print("first job name : " + job[0].jobName);
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
}
