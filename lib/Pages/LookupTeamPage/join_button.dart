import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as user_data;

class JoinButton extends StatelessWidget {
  final String _teamName;
  final String _email = user_data.userEmail;

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

  Future<void> _joinTeam() async {
    //teamに自分の情報を追加
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .document(_email)
        .setData(<String, dynamic>{'email': _email, 'name': user_data.userName});

    // 自分の情報にチームの情報を追加
    // last_visitedもここで現在時間を追加する
    Firestore.instance
        .collection('users')
        .document(_email)
        .collection('teams')
        .document(_teamName)
        .setData(<String, dynamic>{
      'team_name': _teamName,
      'last_visited': Timestamp.now(),
    });

    // チームの参加人数を取得
    final DocumentSnapshot snapshot = await Firestore.instance.collection('teams').document(_teamName).get();

    // チームの参加人数を1増やしてプッシュ
    final int userNum = (snapshot.data['user_num'] as int) + 1;
    Firestore.instance.collection('teams').document(_teamName).updateData(<String, num>{'user_num': userNum});

    // hasNewChatの辞書に追加
    // 入った最初からChatの赤ぽちあるのも変な話なので初期値はFalseにしておく
    user_data.hasNewChat[_teamName] = false;
  }
}
