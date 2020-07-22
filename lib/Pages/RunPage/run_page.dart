import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/RunPage/to_mesurement_page_button.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';

class RunPage extends StatefulWidget {
  @override
  RunPageState createState() => RunPageState();
}

class RunPageState extends State<RunPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ランページ"),
      ),
      body: Column(
        children: <Widget>[
          Text("走る準備ができたら押してください"),
          ToMeasurementPageButton()
        ],
      ),
      drawer: Sidemenu(),
    );
  }
}