import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef TeamJoinCallback = void Function();

class JoinButton extends StatelessWidget{

  String _teamName;
  String _email;
  final TeamJoinCallback callback;

  JoinButton(this._teamName, this._email, this.callback) : super();

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
            }),
      ),
    );
  }

  void _joinTeam(){
    //teamに自分の情報を追加
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .document()
        .setData({'email': _email});

    //自分の情報にチームの情報を追加

    getData() async {
      return await Firestore.instance
          .collection('users')
          .where("email", isEqualTo: _email)
          .getDocuments();
    }
    getData().then((val) {
      //データの更新
      if (val.documents.length > 0) {
        String userDocId = val.documents[0].documentID;
        Firestore.instance
            .collection('users')
            .document(userDocId)
            .collection('teams')
            .document()
            .setData({'team_name': _teamName});
      } else {
        print("Not Found");
      }
    });

    //コールバック
    callback();
  }
}