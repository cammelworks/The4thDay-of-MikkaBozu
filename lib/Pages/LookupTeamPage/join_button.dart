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
      child: FlatButton(
          child: const Text('参加'),
          textColor: Theme.of(context).primaryColor,
          onPressed: () async {
            //チームに参加
            _joinTeam();
            //前のページに戻る
            Navigator.pop(context);
          }),
    );
  }

  void _joinTeam() async {
    //teamに自分の情報を追加
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .document(_email)
        .setData(<String, dynamic>{'email': _email, 'name': userData.userName});

    //自分の情報にチームの情報を追加
    Firestore.instance
        .collection('users')
        .document(_email)
        .collection('teams')
        .document(_teamName)
        .setData(<String, dynamic>{'team_name': _teamName});
    
    // チームの参加人数を取得
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('teams')
        .document(_teamName)
        .get();
    
    // チームの参加人数を1増やしてプッシュ
    int userNum = (snapshot.data['user_num'] as int) + 1;
    Firestore.instance
      .collection('teams')
      .document(_teamName)
      .updateData(<String, num>{'user_num': userNum});
  }
}
