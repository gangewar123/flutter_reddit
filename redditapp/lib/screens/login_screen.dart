import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redditapp/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passController = new TextEditingController();
  bool isLoading = false;

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
            // color: Colors.blue[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 150.0,
                  width: 150.0,
                  // color: Colors.blue[50],
                  child: Image.network(
                      "http://pngriver.com/wp-content/uploads/2018/04/Download-Reddit-Free-PNG-Image.png"),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          labelText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                    ),
                    SizedBox(
                      height: 15.0,
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
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          child: RaisedButton(
                              child: Text("Signup"),
                              color: Colors.orange[800],
                              textColor: Colors.white,
                              elevation: 7.0,
                              onPressed: () {
                                Navigator.of(context).pushNamed('/signup');
                              }),
                        ),
                        RaisedButton(
                          child: Text("Login"),
                          color: Colors.blue,
                          textColor: Colors.white,
                          elevation: 7.0,
                          onPressed: _loginPressed,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text("Forgot password ?")
                  ],
                ),
              ],
            ),
          ),
        ],
      )));
    }
  }

  void _loginPressed() {
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
    var password = _passController.text;
    if (password.length < 6) {
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
    setState(() {
      isLoading = true;
    });
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((FirebaseUser user) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  email: email,
                )),
      );
    }).catchError((e) {
      AlertDialog dialog = new AlertDialog(
        title: new Text("user not exist please Signup",
            style: TextStyle(color: Colors.red)),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      print("error $e");
      setState(() {
        isLoading = false;
      });
    });
  }
}
