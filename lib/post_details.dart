import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostDetails extends StatefulWidget {
  List<DocumentSnapshot> documents;
  String userId;
  int index;
  String userImage;
  String userName;
  PostDetails(
      {this.documents, this.index, this.userId, this.userImage, this.userName});

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
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
      backgroundColor: Colors.orange[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: media.size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                  color: Colors.orange[800]),
              padding: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 80.0,
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                        color: Colors.black54,
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
                    color: Colors.blue,
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
                  color: Colors.orange[100],
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
                          color: Colors.brown,
                          style: BorderStyle.solid,
                          width: 2.0),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    border: new OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.brown,
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
    return Column(
      children: <Widget>[
        Container(
            color: Colors.blue[50],
            padding: EdgeInsets.only(top: 10.0),
            child: ListTile(
              leading: Container(
                height: 50.0,
                width: 50.0,
                decoration: new BoxDecoration(
                    color: const Color.fromRGBO(247, 64, 106, 1.0),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(5.0)),
                    image: new DecorationImage(
                        fit: BoxFit.fill, image: new NetworkImage(avatarUrl))),
              ),
              title: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: new Text("$username",
                        style: Theme.of(context).textTheme.subhead),
                  ),
                  Text(
                    "${timestamp.substring(0, 10)}",
                    style: TextStyle(color: Colors.black45),
                  )
                ],
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  comment,
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                ),
              ),
              trailing: InkWell(
                onTap: () {
                  _displayDialog(context);
                },
                child: Text(
                  "Reply",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            )),
        Divider(),
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
                color: Colors.orange[800],
                child: new Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                color: Colors.orange[800],
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
