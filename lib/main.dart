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

class ChatScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title:new Text('Crackling Spark')
        ),
    );
  }
}