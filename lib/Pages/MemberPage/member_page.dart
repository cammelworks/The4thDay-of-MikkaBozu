import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MemberPage extends StatefulWidget {
  String _email;
  //コンストラクタ
  MemberPage(this._email);
  @override
  State<StatefulWidget> createState() => MemberPageState(_email);
}

class MemberPageState extends State<MemberPage> {
  String _email;
  //コンストラクタ
  MemberPageState(this._email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_email),
      ),
      body: Text(_email)
    );
  }
}