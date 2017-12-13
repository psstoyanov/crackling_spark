import 'package:flutter/material.dart';


void main(){
  runApp(new CracklingsparkApp());
}

class CracklingsparkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: 'Crackling Spark',
      home: new ChatScreen(),
    );
  }
}

// Modify the ChatScreen class definition to extend StatefulWidget.
class ChatScreen extends StatefulWidget{
  @override
  State createState() => new ChatScreenState();
}

// Add the ChatScreenState class definition in main.dart.
class ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title:new Text('Crackling Spark')
        ),
    );
  }
}