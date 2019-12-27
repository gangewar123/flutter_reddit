import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadPost extends StatefulWidget {
  List<DocumentSnapshot> documents;
  String email;
  UploadPost({this.documents, this.email});

  @override
  UploadPostState createState() {
    return new UploadPostState();
  }
}

class UploadPostState extends State<UploadPost> {
  bool _loading = false;
  File sampleImage;
  String newsTitle;
  String newsDescription;
  String userId;
  String postId;
  String uploaderImage;
  String timeStamp;
  String userName;
  Future getImage(var imagesource) async {
    var tempImage = await ImagePicker.pickImage(source: imagesource);

    setState(() {
      sampleImage = tempImage;
    });
  }

  String _path;

  Future<Null> upload() async {
    setState(() {
      _loading = true;
    });
    Firestore.instance
        .collection('users')
        .where("email", isEqualTo: widget.email)
        .snapshots()
        .listen((onData) {
      setState(() {
        userId = onData.documents[0].data['uid'];
        postId = DateTime.now().millisecondsSinceEpoch.toString() +
            onData.documents[0].data['email'];
        uploaderImage = onData.documents[0].data['userImage'];
        userName = onData.documents[0].data['displayName'];
        timeStamp = DateTime.now().toString();
      });
    });
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("${Random().nextInt(10000)}.jpg");
    StorageUploadTask uploadTask = ref.putFile(sampleImage);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    _path = downloadUrl.toString();

    print("this is my path $_path");
    Firestore.instance.collection('News_Feed').document(postId).setData({
      "title": newsTitle,
      "pid": postId,
      "uid": userId,
      "description": newsDescription,
      "uploaderImage": uploaderImage,
      "timeStamp": timeStamp,
      "username": userName,
      "postedImage": _path
    });

    setState(() {
      _loading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var body = ListView(children: <Widget>[
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          Container(
              height: 200.0,
              width: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(const Radius.circular(15.0)),
                border: Border.all(width: 2.0, color: Colors.orange[800]),
                color: Colors.cyan,
              ),
              child: InkWell(
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
                child: Center(
                  child: sampleImage == null
                      ? Text(
                          " Upload image",
                          style: TextStyle(color: Colors.white),
                        )
                      : Image.file(
                          sampleImage,
                          height: 200.0,
                          width: 200.0,
                        ),
                ),
              )),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          TextField(
            maxLines: null,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                hintText: 'Add post title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            // initialValue: "title",
            onChanged: (String item) {
              newsTitle = item;
              print(newsTitle);
            },
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 100.0,
              child: TextField(
            decoration: InputDecoration(
                hintText: 'Add post descriptiocn',
                border: OutlineInputBorder(
                  
                    borderRadius: BorderRadius.circular(10.0))),
            maxLines: null,
            textInputAction: TextInputAction.done,
            scrollPadding: const EdgeInsets.all(200.0),
            // initialValue: "title",
            onChanged: (String item) {
              newsDescription = item;
            },
          )),
          Container(
            height: media.size.height*.06,
            width: media.size.width*.9,
            child: RaisedButton(
              child: Text("Upload"),
              color: Colors.orange[800],
              textColor: Colors.white,
              elevation: 7.0,
              onPressed: upload,
            ),
          ),
        ],
      )
    ]);

    var bodyProgress = new Container(
      child: new Stack(
        children: <Widget>[
          body,
          new Container(
            alignment: AlignmentDirectional.center,
            decoration: new BoxDecoration(
              color: Colors.white70,
            ),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: new BorderRadius.circular(10.0)),
              width: media.size.width*.8,
              height: media.size.height*.6,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: new Center(
                      child: new Text(
                        "Uploading.. wait...",
                        style: new TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        title: Text("Add new post"),
        centerTitle: true,
        backgroundColor: Colors.orange[800],
      ),
      body: Center(
        child: _loading ? bodyProgress : body,
      ),
    );
  }
}
