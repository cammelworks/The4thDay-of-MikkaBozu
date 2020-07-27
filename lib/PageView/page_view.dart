import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/my_page.dart';
import 'package:the4thdayofmikkabozu/Pages/RunPage/run_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamMainPage/team_main_page.dart';

class MyPageView extends StatefulWidget {
  @override
  MyPageViewState createState() => MyPageViewState();
}

class MyPageViewState extends State<MyPageView> {
  int _page = 0;
  static List<Widget> _pageList = [
    MyPage(),
    RunPage(),
    TeamMainPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageList[_page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        currentIndex: _page,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.equalizer),
              title: Text("記録")
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              title: Text("ラン")
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text("チーム関連")
          ),
        ],
      ),
    );
  }

  void onTap(int page) {
    setState(() {
      _page = page;
    });
  }
}