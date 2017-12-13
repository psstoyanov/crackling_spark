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

class ChatScreen extends StatefulWidget{
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  // Add a TextEditingController to manage the interaction with the text field
  final TextEditingController _textController = new TextEditingController();

  Widget _buildTextComposer(){
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new TextField(
        controller: _textController,
        onSubmitted: _handleSubmitted,
        decoration: new InputDecoration.collapsed(
          hintText: "Send text message"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title:new Text('Crackling Spark')
        ),
        body: _buildTextComposer(),
    );
  }

  void _handleSubmitted(String value) {
      _textController.clear();
  }
}