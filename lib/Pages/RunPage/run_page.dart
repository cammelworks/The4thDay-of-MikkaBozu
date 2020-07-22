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
          SizedBox(
            height: 60,
          ),
          Text(
              "走る準備ができたら押してください",
            style: TextStyle(
              fontSize: 18
            ),
          ),
          ToMeasurementPageButton()
        ],
      ),
      drawer: Sidemenu(),
    );
  }
}