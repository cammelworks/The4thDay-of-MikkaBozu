import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/my_page.dart';
import 'package:the4thdayofmikkabozu/Pages/RunPage/run_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamMainPage/team_main_page.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class MyPageView extends StatefulWidget {
  @override
  MyPageViewState createState() => MyPageViewState();
}

class MyPageViewState extends State<MyPageView> {
  int _page = 0;
  static List<Widget> _pageList = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _pageList.add(MyPage());
    _pageList.add(RunPage());
    _pageList.add(TeamMainPage(update));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageList[_page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        currentIndex: _page,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), title: Text("記録")),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), title: Text("ラン")),
          BottomNavigationBarItem(
              icon: Stack(
                overflow: Overflow.visible,
                children: [
                  Icon(Icons.people),
                  Positioned(
                    top: -8,
                    left: 20,
                    child: Visibility(
                      visible: checkNewChat(),
                      child: Icon(
                        Icons.brightness_1,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
              title: Text("チーム関連")),
        ],
      ),
    );
  }

  void onTap(int page) {
    setState(() {
      _page = page;
    });
  }

  bool checkNewChat() {
    bool res = false;
    userData.hasNewChat.forEach((key, value) {
      if (value) {
        res = true;
      }
    });
    return res;
  }

  void update() {
    print("update");
    setState(() {});
  }
}
