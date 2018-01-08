// Base libs for the app
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// Libs for randomly generated name to the files and IO
import 'dart:math';
import 'dart:io';

// Asyn package
import 'dart:async';

// Google signin package
import 'package:google_sign_in/google_sign_in.dart';
// Firebase auth
import 'package:firebase_auth/firebase_auth.dart';  

// Firebase database and additional lib for UI enhancement
import 'package:firebase_database/firebase_database.dart'; 
import 'package:firebase_database/ui/firebase_animated_list.dart';

// Firebase storage plugin to support file sharing (photos)
import 'package:firebase_storage/firebase_storage.dart';

// Firebase analytics
import 'package:firebase_analytics/firebase_analytics.dart';

// SignIn and User auth
final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

// Analytics
final analytics = new FirebaseAnalytics();

const String _name = "Your Name";

// Defining the theme data.
final ThemeData kIOSTheme = new ThemeData(
    primarySwatch: Colors.purple,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.purple, accentColor: Colors.purpleAccent[400]);

void main() {
  runApp(new CracklingsparkApp());
}

class CracklingsparkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Crackling Spark',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: new ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>{
  final firebaseDBReference = FirebaseDatabase.instance.reference().child('messages');
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  // Widget to entering and sending messages.
  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Container( // Upload photo button
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.photo_album),
                onPressed: () async {
                  await _ensureLoggedIn();
                  File imageFile = await ImagePicker.pickImage();
                  // Use random image name and upload to Firebase
                  int random = new Random().nextInt(10000);
                  StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
                  StorageUploadTask uploadTask = ref.put(imageFile);
                  Uri downloadUri = (await uploadTask.future).downloadUrl;
                  _sendMessage(imageUrl: downloadUri.toString());
                }
              ),
            ),
            new Flexible(
              child: new TextField( // Message field
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Send text message"),
              ),
            ),
            new Container( // Submit message button
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton( // iOS style submit button
                        child: new Text("Send"),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )
                    : new IconButton( // Android style submit button
                        icon: new Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Crackling Spark'),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: new Column(children: <Widget>[
            new Flexible(
                child: new FirebaseAnimatedList(
                  query: firebaseDBReference,
                  sort: (a, b) => b.key.compareTo(a.key),
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation){
                    return new ChatMessage(
                      snapshot: snapshot,
                      animation: animation
                    );
                  },
                )),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border:
                      new Border(top: new BorderSide(color: Colors.grey[500])))
              : null,
        ));
  }

  // Handle message submission
  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    await _ensureLoggedIn();
    _sendMessage(text: text);
  }

  // Handle sending a message logic after the user is ensured to be logged in.
  void _sendMessage({String text, String imageUrl}) {
    // Push the message to the Firebase db reference
    firebaseDBReference.push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': googleSignIn.currentUser.displayName,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl
    });
    analytics.logEvent(name: 'send message');
  }

  // Ensure the user is logged in
  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }
    if (user == null) {
      await googleSignIn.signIn();
      analytics.logLogin();
    }
    // Ensure the user has logged in
    if(await auth.currentUser() == null){
      GoogleSignInAuthentication credentials = 
      await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken
      );
    }
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animation, curve: Curves.decelerate),
        axisAlignment: -20.0, // Useful to make the animation more "believable"
        child: new FadeTransition(
          opacity: new CurvedAnimation(
              parent: animation,
              curve: const Interval(0.6, 1.0, curve: Curves.linear)),
          child: new Container(
            margin: new EdgeInsets.symmetric(vertical: 8.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: new EdgeInsets.only(right: 16.0),
                  child: new CircleAvatar(
                      backgroundImage:
                          new NetworkImage(snapshot.value['senderPhotoUrl'])),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(snapshot.value['senderName'],
                          style: Theme.of(context).textTheme.subhead),
                      new Container( // Display the image or text from the message
                        margin: const EdgeInsets.only(top: 5.0),
                        child: snapshot.value['imageUrl'] != null ?
                        new Image.network(
                          snapshot.value['imageUrl'],
                          width: 250.0,
                        ) :
                        new Text(snapshot.value['text']),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
