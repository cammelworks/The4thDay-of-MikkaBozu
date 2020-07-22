import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/records_screen.dart';

class MyPage extends StatefulWidget {
  final String title = '記録ページ';
  MyPage();
  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Center(
                  //距離のデータを表示
                  child: RecordsScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Sidemenu(),
    );
  }
}