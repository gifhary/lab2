import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_pickup/job.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'theme/theme.dart' as Theme;
import 'package:url_launcher/url_launcher.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(JobDetailPage());

class JobDetailPage extends StatefulWidget {
  final Job job;
  final Function(String) delete;
  final Function(String, double) update;

  JobDetailPage({Key key, this.job, this.delete, this.update});

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  String _driverNum = "";
  List<String> _locNames;
  double _finalRating;
  double _rating = 0;

  bool _loginStatus = false;

  @override
  void initState() {
    super.initState();
    _locNames = widget.job.jobLocNames.split(",");
    _finalRating = widget.job.jobRating;

    _checkLogin().then((onValue) {
      setState(() {
        _loginStatus = onValue;
      });
    });

    if (widget.job.driverEmail != null) {
      _getDriverNum(widget.job.driverEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.job.jobName),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.delete,
              ),
              onPressed: _onDelete,
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 10),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Pickup ID"),
                        SizedBox(height: 10),
                        Text("Fare"),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(widget.job.jobId),
                        SizedBox(height: 10),
                        Text("RM " + widget.job.jobPrice),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _loginStatus
                          ? "Description"
                          : "Phone",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(widget.job.jobDesc),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.location_searching, color: Colors.blue),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(_locNames[0]),
                            )
                          ],
                        ),
                        Icon(Icons.more_vert),
                        Row(
                          children: <Widget>[
                            Icon(Icons.location_on, color: Colors.red),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(_locNames[1]),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  widget.job.driverEmail != null
                      ? ListTile(
                          title: Column(
                            children: <Widget>[
                              Text("Rate the Ride"),
                              _finalRating > 0
                                  ? RatingBar.readOnly(
                                      initialRating: widget.job.jobRating,
                                      filledIcon: Icons.star,
                                      emptyIcon: Icons.star_border,
                                      filledColor: Colors.amberAccent,
                                      emptyColor: Colors.grey,
                                    )
                                  : Column(
                                      children: <Widget>[
                                        RatingBar(
                                          onRatingChanged: (rating) =>
                                              setState(() => _rating = rating),
                                          filledIcon: Icons.star,
                                          emptyIcon: Icons.star_border,
                                          halfFilledIcon: Icons.star_half,
                                          isHalfAllowed: true,
                                          filledColor: Colors.amberAccent,
                                          emptyColor: Colors.grey,
                                          size: 40,
                                        ),
                                        SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: _updateRating,
                                          child: Text("Submit",
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.blue,
                                                  fontSize: 20)),
                                        )
                                      ],
                                    )
                            ],
                          ),
                        )
                      : SizedBox(height: 5)
                ],
              ),
            ),
            _driverNum != ""
                ? MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    minWidth: 200,
                    height: 50,
                    child: Text(
                      'Call Driver',
                      style: new TextStyle(
                          fontSize: 17.0,
                          color: Theme.darkThemeData.primaryColorDark),
                    ),
                    color: Theme.darkThemeData.primaryColor,
                    elevation: 15,
                    onPressed: _callDriver,
                  )
                : SizedBox(
                    height: 50,
                  ),
            SizedBox(
              height: 5,
            )
          ],
        ));
  }

  void _updateRating() {
    print("rating: " + _rating.toString());
    String url =
        "http://pickupandlaundry.com/my_pickup/gifhary/update_rating.php";

    if (_rating > 0) {
      http.post(url, body: {
        "job_id": widget.job.jobId,
        "job_rating": _rating.toString(),
      }).then((res) {
        print("response : " + res.body);
        Toast.show(res.body, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (res.body == "success") {
          setState(() {
            _finalRating = _rating;
            widget.update(widget.job.jobId, _rating);
          });
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      Toast.show("Please tap at least one star", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _getDriverNum(String email) {
    String url =
        "http://pickupandlaundry.com/my_pickup/chan/php/get_contact_gifhary.php";

    http.post(url, body: {
      "driver_email": email,
    }).then((res) {
      print("http response : " + res.body);

      if (res.body != "failed") {
        var userData = json.decode(res.body);
        print("driver phone : " + userData['driver_phone']);
        setState(() {
          _driverNum = userData['driver_phone'];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _callDriver() async {
    String url = "tel://" + _driverNum;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Toast.show("Error ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> _onDelete() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: Text(
                "Are you sure want to delete '" + widget.job.jobName + "' ?"),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text('Delete'),
              onPressed: _delete,
            ),
          ],
        );
      },
    );
  }

  void _delete() {
    Navigator.of(context).pop();
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/delete_job.php';

    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting pickup detail");
    pr.show();

    http.post(url, body: {
      "job_id": widget.job.jobId,
    }).then((res) {
      print(res.statusCode);
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      pr.dismiss();
      if (res.body == "success") {
        widget.delete(widget.job.jobId);
        Navigator.of(context).pop();
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<bool> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return null != prefs.getString('email');
  }
}
