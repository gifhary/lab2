import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_pickup/payment.dart';
import 'package:my_pickup/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'theme/theme.dart' as Theme;
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

void main() => runApp(ProfilePage());

String _value;

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({Key key, this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _profilePath = 'asset/img/profile.png';
  String _avatarUrl = "";

  String _email = "";
  String _username = "";
  String _phone = "";
  String _credit = "0";

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _email = widget.user.email;
      _username = widget.user.name;
      _phone = widget.user.phone;
      _credit = widget.user.credit;

      _avatarUrl =
          "http://pickupandlaundry.com/my_pickup/gifhary/profile/$_email.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                color: Theme.darkThemeData.primaryColor,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () => mainBottomSheet(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            imageUrl: _avatarUrl,
                            errorWidget: (context, url, error) =>
                                Image.asset(_profilePath),
                          ),
                        ),
                      ),
                    ),
                    Text(_username, style: TextStyle(fontSize: 24)),
                    SizedBox(height: 15),
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 5, 18, 5),
                        child: Column(
                          children: <Widget>[
                            Text("Credits", style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            Text(_credit,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.darkThemeData.primaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 40),
            Row(
              children: <Widget>[
                SizedBox(width: 40),
                Icon(Icons.email),
                SizedBox(width: 20),
                Flexible(
                  child: Text(_email, style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                SizedBox(width: 40),
                Icon(Icons.phone_android),
                SizedBox(width: 20),
                Flexible(
                  child: Text(_phone, style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.only(left: 100, right: 100),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                height: 50,
                child: Text(
                  'Top Up Credit',
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Theme.darkThemeData.primaryColorDark),
                ),
                color: Theme.darkThemeData.primaryColor,
                elevation: 15,
                onPressed: _topUpDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _topUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Top Up"),
          content: Container(
            height: 100,
            child: DropdownExample(),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                Navigator.of(context).pop();
                var now = new DateTime.now();
                var formatter = new DateFormat('ddMMyyyyhhmmss-');
                String formatted =
                    formatter.format(now) + randomAlphaNumeric(10);
                print(formatted);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage(
                            user: widget.user,
                            orderid: formatted,
                            val: _value)));
              },
            ),
          ],
        );
      },
    );
  }

  //bottom sheet menu for taking profile picture
  void mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(title: Text("Update Picture")),
              _createTile(context, 'Camera', Icons.camera, _action1),
              _createTile(context, 'Gallery', Icons.photo_library, _action2),
            ],
          );
        });
  }

  ListTile _createTile(
      BuildContext context, String name, IconData icon, Function action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  //Take profile picture from camera
  _action1() async {
    print('action camera');
    File _cameraImage;

    _cameraImage = await ImagePicker.pickImage(source: ImageSource.camera);
    if (_cameraImage != null) {
      //Avoid crash if user cancel picking image
      _updateImage(_cameraImage);
    }
  }

  //Take profile picture from gallery
  _action2() async {
    print('action gallery');
    File _galleryImage;

    _galleryImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_galleryImage != null) {
      //Avoid crash if user cancel picking image
      _updateImage(_galleryImage);
    }
  }

  void _updateImage(File file) {
    String base64Image = base64Encode(file.readAsBytesSync());
    String urlUpload =
        "http://pickupandlaundry.com/my_pickup/gifhary/update_image.php";

    http.post(urlUpload, body: {
      "encoded_string": base64Image,
      "email": _email,
    }).then((res) {
      print(res.statusCode);
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      setState(() {
        //empty all cache, included profile image so it can be updated
        DefaultCacheManager().emptyCache();
      });
    }).catchError((err) {
      print(err);
    });
  }
}

class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() {
    return _DropdownExampleState();
  }
}

class _DropdownExampleState extends State<DropdownExample> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        items: [
          DropdownMenuItem<String>(
            child: Text('50 HCredit (RM10)'),
            value: '10',
          ),
          DropdownMenuItem<String>(
            child: Text('100 HCredit (RM20)'),
            value: '20',
          ),
          DropdownMenuItem<String>(
            child: Text('150 HCredit (RM30)'),
            value: '30',
          ),
        ],
        onChanged: (String value) {
          setState(() {
            _value = value;
          });
        },
        hint: Text('Select Credit'),
        value: _value,
      ),
    );
  }
}
