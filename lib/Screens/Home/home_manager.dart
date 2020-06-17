import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/join_button.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/sidemenu.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/signout_button.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/teams_screen.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/record_form.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/records_screen.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/teams_dropdownbutton.dart';

import 'signin_screen.dart';
import 'sidemenu.dart';

class HomeManager {
  final VoidCallback updateStateCallback;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user = null;
  String _teamName = null;

  HomeManager({@required this.updateStateCallback}) : super();

  //ログインの有無によって表示を変える関数
  Widget showButton() {
    if (_user == null) {
      return getSigninScreen();
    } else {
      return getHomeScreen();
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

  Widget showJoinButton() {
    if (_teamName != null) {
      //登録ボタンの表示
      return JoinButton(_teamName, _user.email, () {
        _teamName = null;
        updateStateCallback();
      });
    } else {
      //何も表示しない
      return null;
    }
  }

  Widget showSidemenu() {
    if (_user != null) {
      //サイドメニューの表示
      return Sidemenu(_user.email);
    } else {
      //何も表示しない
      return null;
    }
  }
}
