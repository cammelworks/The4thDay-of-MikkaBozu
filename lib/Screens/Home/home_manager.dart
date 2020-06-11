import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/join_button.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/lookup_team.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/signout_button.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/teams_screen.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/record_form.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/records_screen.dart';

import 'signin_screen.dart';
import 'team_create_button.dart';

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
            child: LookupTeam(_teamName, (String teamName) {
          _teamName = teamName;
          updateStateCallback();
        })),
        Center(
          child: showJoinButton(),
        ),
        Center(
          //メールアドレスと参加チームIDの表示
          child: TeamsScreen(_user.email),
        ),
        Center(
          //走った距離を入力するフォーム
          child: RecordForm(_user.email),
        ),
        Center(
          //距離のデータを表示
          child: RecordsScreen(_user.email),
        ),
      ],
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
}
