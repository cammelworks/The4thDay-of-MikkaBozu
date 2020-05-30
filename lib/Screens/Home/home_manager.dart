import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/signout_button.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/teams_screen.dart';

import 'signin_screen.dart';
import 'team_create_button.dart';

class HomeManager {
  final VoidCallback updateStateCallback;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user = null;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          //チーム作成ボタンの表示
          child: TeamCreateButton(_user.email),
        ),
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
      ],
    );
  }
}
