import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pickup/user.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'login.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/theme.dart' as Theme;

String _profilePath = 'asset/img/profile.png';
String urlUpload = 'http://pickupandlaundry.com/my_pickup/gifhary/register.php';
File _image;
final TextEditingController _namecontroller = TextEditingController();
final TextEditingController _emcontroller = TextEditingController();
final TextEditingController _passcontroller = TextEditingController();
final TextEditingController _phcontroller = TextEditingController();
String _name, _email, _password, _phone;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
  const RegisterPage({Key key, File image}) : super(key: key);
}

class _RegisterUserState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            child: RegisterWidget(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    _image = null;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
    return Future.value(false);
  }
}

class RegisterWidget extends StatefulWidget {
  @override
  RegisterWidgetState createState() => RegisterWidgetState();
}

class RegisterWidgetState extends State<RegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        GestureDetector(
            onTap: () => mainBottomSheet(context),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _image == null
                        ? AssetImage(_profilePath)
                        : FileImage(_image),
                    fit: BoxFit.fill,
                  )),
            )),
        Text(_image == null ? 'Tap image to set profile picture' : '',
            style: new TextStyle(fontSize: 16.0)),
        TextField(
            controller: _emcontroller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              icon: Icon(Icons.email),
            )),
        TextField(
            controller: _namecontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Name',
              icon: Icon(Icons.person),
            )),
        TextField(
          controller: _passcontroller,
          decoration: InputDecoration(
            labelText: 'Password',
            icon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        TextField(
            controller: _phcontroller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              icon: Icon(Icons.phone),
            )),
        SizedBox(
          height: 20,
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          minWidth: 300,
          height: 50,
          child: Text('Register',
              style: new TextStyle(
                  fontSize: 20.0, color: Theme.darkThemeData.primaryColorDark)),
          color: Theme.darkThemeData.primaryColor,
          elevation: 15,
          onPressed: _onRegister,
        ),
        SizedBox(
          height: 10,
        ),
      ],
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
      _image = _cameraImage;
      setState(() {});
    }
  }

  //Take profile picture from gallery
  _action2() async {
    print('action gallery');
    File _galleryImage;

    _galleryImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_galleryImage != null) {
      //Avoid crash if user cancel picking image
      _image = _galleryImage;
      setState(() {});
    }
  }

  void _onRegister() {
    print('onRegister Button from RegisterUser()');
    print(_image.toString());
    uploadData();
    //Saving profile img
    saveProfileImg();

    //saving register info into preferences and automaticly logged in
    saveRegisterInfo(_email);
  }

  void uploadData() {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    _phone = _phcontroller.text;

    if ((_isEmailValid(_email)) && (_image != null) && (_phone.length > 5)) {
      if (_password.length > 5) {
        ProgressDialog pr = new ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: false);
        pr.style(message: "Registration in progress");
        pr.show();

        String base64Image = base64Encode(_image.readAsBytesSync());
        http.post(urlUpload, body: {
          "encoded_string": base64Image,
          "name": _name,
          "email": _email,
          "password": _password,
          "phone": _phone,
        }).then((res) {
          print(res.statusCode);
          Toast.show(res.body, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

          if (res.body == "success") {
            pr.dismiss();
            User user = new User(name: _name, email: _email, phone: _phone);
            _image = null;
            _namecontroller.text = '';
            _emcontroller.text = '';
            _phcontroller.text = '';
            _passcontroller.text = '';

            //Move to home page after register
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => HomePage(user: user)));
          } else {
            pr.dismiss();
          }
        }).catchError((err) {
          print(err);
        });
      } else {
        Toast.show("Password minimum is 6 characters", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      Toast.show("Please complete all the field", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void saveRegisterInfo(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  void saveProfileImg() {
    //TODO safe profile image into local directory
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
