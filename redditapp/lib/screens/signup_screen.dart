import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reddit_app/services/user_management.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _firstName;
  String _phoneNumber;
  File sampleImage;
  String _path;
  bool isLoading = false;

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _confirmPassController =
      new TextEditingController();

  Future getImage(var imagesource) async {
    var tempImage = await ImagePicker.pickImage(source: imagesource);

    setState(() {
      sampleImage = tempImage;
    });
  }

  Future<Null> uploadProfile() async {}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: new SizedBox(
          height: 50.0,
          width: 50.0,
          child: new CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
          ),
        ),
      );
    } else {
      return new Scaffold(
          body: Center(
              child: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(25.0),
              color: Colors.grey[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      iconSize: 40.0,
                                      onPressed: () {
                                        getImage(ImageSource.camera);

                                        Navigator.pop(context);
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.image),
                                      iconSize: 40.0,
                                      onPressed: () {
                                        getImage(ImageSource.gallery);

                                        Navigator.pop(context);
                                      })
                                ]));
                          });
                    },
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      alignment: FractionalOffset.center,
                      decoration: new BoxDecoration(
                        color: const Color.fromRGBO(247, 64, 106, 1.0),
                      ),
                      child: sampleImage == null
                          ? new Text(
                              "Add photo",
                              style: new TextStyle(
                                color: Colors.amber,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.3,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(50.0))),
                              child: Image.file(sampleImage)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextField(
                    decoration: InputDecoration(
                        hintText: 'First name',
                        labelText: "First name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    onChanged: (value) {
                      setState(() {
                        _firstName = value;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextField(
                    decoration: InputDecoration(
                        hintText: 'Phone',
                        labelText: "Phone",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextField(
                    controller: _passController,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: "Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    obscureText: true,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextField(
                    controller: _confirmPassController,
                    decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        labelText: "Re-enter password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    obscureText: true,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Back"),
                        color: Colors.blue,
                        textColor: Colors.white,
                        elevation: 7.0,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      RaisedButton(
                        child: Text("Signup"),
                        color: Colors.blue,
                        textColor: Colors.white,
                        elevation: 7.0,
                        onPressed: _signupPressed,
                      ),
                    ],
                  )
                ],
              )),
        ],
      )));
    }
  }

  void _signupPressed() async {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    var email = _emailController.text.trim();
    RegExp exp = new RegExp(p);
    if (!exp.hasMatch(email)) {
      AlertDialog dialog = new AlertDialog(
        title:
            new Text("Email is not valid", style: TextStyle(color: Colors.red)),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return;
    }
    var pass = _passController.text;
    if (pass.length < 6) {
      AlertDialog dialog = new AlertDialog(
        title: new Text("Password is too short",
            style: TextStyle(color: Colors.red)),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return;
    }

    var confirmPass = _confirmPassController.text;
    if (confirmPass != pass) {
      AlertDialog dialog = new AlertDialog(
        title: new Text("Passwords didn't match",
            style: TextStyle(color: Colors.red)),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return;
    }
    setState(() {
      isLoading = true;
    });
    _emailController.clear();
    _passController.clear();
    _confirmPassController.clear();
    setState(() => isLoading = true);
    if (sampleImage != null) {
      final StorageReference ref = FirebaseStorage.instance
          .ref()
          .child("${Random().nextInt(10000)}.jpg");
      StorageUploadTask uploadTask = ref.putFile(sampleImage);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      _path = downloadUrl.toString();
    }
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass)
        .then((signedInUser) {
      UserManagement()
          .storeNewUser(_firstName, _phoneNumber, signedInUser, _path, context);
    }).catchError((e) {
      print(e);
      AlertDialog dialog = new AlertDialog(
        title: new Text(
            "Wrong or already used credentials, please enter correct detalis",
            style: TextStyle(color: Colors.blue)),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
    });
    setState(() {
      isLoading = false;
    });
  }
}
