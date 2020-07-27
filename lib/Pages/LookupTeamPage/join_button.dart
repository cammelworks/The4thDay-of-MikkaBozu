import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class JoinButton extends StatelessWidget {
  String _teamName;
  String _email = userData.userEmail;

  JoinButton(this._teamName) : super();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ButtonTheme(
        minWidth: 200.0,
        height: 50.0,
        buttonColor: Colors.white,
        child: RaisedButton(
            child: const Text('参加'),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            onPressed: () async {
              //チームに参加
              _joinTeam();
              //前のページに戻る
              Navigator.pop(context);
            }),
      ),
    );
  }

  void _joinTeam() {
    //teamに自分の情報を追加
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .document(_email)
        .setData(<String, dynamic>{'email': _email});

    //自分の情報にチームの情報を追加
    Firestore.instance
        .collection('users')
        .document(_email)
        .collection('teams')
        .document(_teamName)
        .setData(<String, dynamic>{'team_name': _teamName});
  }
}
