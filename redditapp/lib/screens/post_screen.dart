import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  List<DocumentSnapshot> documents;
  String userId;
  int index;
  String userImage;
  String userName;
  PostScreen(
      {this.documents, this.index, this.userId, this.userImage, this.userName});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String postId;
  String image;
  String title;
  String description;
  String userName;
  TextEditingController _controller;

  @override
  initState() {
    super.initState();
    _controller = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);

    title = widget.documents[widget.index].data['title'].toString();
    description = widget.documents[widget.index].data['description'].toString();
    image = widget.documents[widget.index].data['uploaderImage'].toString();
    postId = widget.documents[widget.index].data['pid'].toString();

    return new Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: media.size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                  color: Colors.blue[800]),
              padding: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50.0,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Comments",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Center(
              child: Container(
                height: 1,
                width: media.size.width,
                color: Colors.cyan,
              ),
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  color: Colors.blue[100],
                  child: buildComments()),
            ),
            Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextFormField(
                  controller: _controller,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: "Post comment..",
                    focusedBorder: new OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black,
                          style: BorderStyle.solid,
                          width: 2.0),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    border: new OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black,
                          style: BorderStyle.solid,
                          width: 2.0),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    hintStyle: new TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  autofocus: false,
                  onFieldSubmitted: (String item) {
                    Firestore.instance
                        .collection("Comments")
                        .document(postId)
                        .collection("comments")
                        .add({
                      "uid": widget.userId,
                      "comment": item,
                      "timestamp": DateTime.now().toString(),
                      "username": widget.userName,
                      "userImage": widget.userImage,
                      "postId": postId,
                    });
                    setState(() {
                      _controller.clear();
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];

    QuerySnapshot data = await Firestore.instance
        .collection("Comments")
        .document(postId)
        .collection("comments")
        .getDocuments();
    data.documents.forEach((DocumentSnapshot doc) {
      comments.add(Comment.fromDocument(doc));
    });

    return comments;
  }

  Widget buildComments() {
    return FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data,
          );
        });
  }
}

class Comment extends StatelessWidget {
  TextEditingController _textFieldController = TextEditingController();
  final String username;
  final String uid;
  final String avatarUrl;
  final String comment;
  final String timestamp;
  final String postId;

  Comment(
      {this.username,
      this.uid,
      this.avatarUrl,
      this.comment,
      this.timestamp,
      this.postId});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
        username: document['username'],
        uid: document['uid'],
        comment: document["comment"],
        timestamp: document["timestamp"],
        avatarUrl: document["userImage"],
        postId: document['postId']);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    return Column(
      children: <Widget>[
        Container(
//        alignment: Alignment.center,
          color: Colors.white,
//    margin: EdgeInsets.all(2),
          width: media.size.width,
          height: media.size.height * 0.14,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: media.size.width * 0.18,
                    height: media.size.height * 0.08,
//                  color: Colors.black12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.grey),
                        color: Colors.black12,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: new NetworkImage(avatarUrl))),
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                "$username",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            margin: EdgeInsets.only(
                              left: 10,
                              top: 10,
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                "Today at 5:42PM",
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 17),
                              ),
                            ),
                            margin: EdgeInsets.only(
                              left: 8,
                              top: 10,
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10, top: 8),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                comment,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 10,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: media.size.width * 0.2,
                    margin: EdgeInsets.only(right: 15),
                    color: Colors.grey,
                  ),
                  InkWell(
                    onTap: () {
                      _displayDialog(context);
                    },
                    child: Text(
                      "Reply",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Reply'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Type here.."),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blue[800],
                child: new Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                color: Colors.blue[800],
                child: new Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Firestore.instance
                      .collection("Comments")
                      .document(postId)
                      .collection("comments")
                      .document(postId)
                      .collection("replies")
                      .add({
                    // "uid": widget.userId,
                    "reply": _textFieldController.text,
                    "timestamp": DateTime.now().toString(),
                    // "username": widget.userName,
                    // "userImage": widget.userImage,
                    "postId": postId,
                  });
                  // setState(() {
                  //   _controller.clear();
                  // });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
