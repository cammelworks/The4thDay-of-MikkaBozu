import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/signout_button.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/teams_screen.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/record_form.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/records_screen.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/teams_dropdownbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signin_screen.dart';
import 'SideMenu/sidemenu.dart';

class HomeManager {
  final VoidCallback updateStateCallback;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user = null;
  String _teamName = null;

  HomeManager({@required this.updateStateCallback}) : super();

  //ログインの有無によって表示を変える関数
  Future<Widget> showButton() async {
    //端末のデータにアクセスするための変数
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_user != null) {
      return getHomeScreen();
    } else if (prefs.getString('password') != null) {
      //自動ログイン
      _user = (await _auth.signInWithEmailAndPassword(
        email: prefs.getString('email'),
        password: prefs.getString('password'),
      ))
          .user;
      return getHomeScreen();
    } else {
      //ログイン画面
      return getSigninScreen();
    }
  }

  //SigninScreenを表示する
  Widget getSigninScreen() {
    return SigninScreen((FirebaseUser user) {
      _user = user;
      updateStateCallback();
    });
  }

  //ログインした後の画面を表示する
  Widget getHomeScreen() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              //サインアウトボタンの表示
              child: SignoutButton(_auth, _user.email, (FirebaseUser user) {
                _user = user;
                updateStateCallback();
              }),
            ),
            Center(
              //メールアドレスと参加チームIDの表示
              child: TeamsScreen(_user.email),
            ),
            Center(
              //参加しているチームをドロップダウンボタンで表示
              child: TeamsDropdownButton(_user.email),
            ),
            Center(
              //走った距離を入力するフォーム
              child: RecordForm(_user.email),
            ),
            Container(
              child: Center(
                //距離のデータを表示
                child: RecordsScreen(_user.email),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> showSidemenu() async {
    if (_user != null) {
      //サイドメニューの表示
      return Sidemenu(_user.email);
    } else {
      //何も表示しない
      return null;
    }
  }
}
