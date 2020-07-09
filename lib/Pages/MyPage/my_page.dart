import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'file:///H:/Cammel/The4thDay-of-MikkaBozu/lib/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/records_screen.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/to_mesurement_page_button.dart';

class MyPage extends StatefulWidget {
  final String title = '三日坊主の四日目';
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
              Center(
                //時間・距離計測ページへ遷移するボタン
                child: ToMeasurementPageButton(),
              ),
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