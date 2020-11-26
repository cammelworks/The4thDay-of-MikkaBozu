import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

class GoalManager extends StatelessWidget {
  String _teamName;

  GoalManager(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            '目標',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: _showGoal()),
            IconButton(
                icon: Icon(Icons.mode_edit),
                onPressed: () async {
                  //目標変更
                  showPickerNumber(context);
                }),
          ],
        ),
      ],
    );
  }

  void showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 9, jump: 1),
          NumberPickerColumn(begin: 0, end: 9, jump: 1),
        ]),
        hideHeader: true,
        title: Text("チーム目標を設定してください"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        confirmText: "決定",
        cancelText: "キャンセル",
        onConfirm: (Picker picker, List values) {
          _setGoal(values[0] * 10 + values[1]);
        }).showDialog(context);
  }

  void _setGoal(dynamic goal) {
    //Firebaseのteamsに目標を設定する
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .updateData(<String, dynamic>{'goal': goal});
  }

  Widget _showGoal() {
    //Firestoreから目標を取得して表示
    return StreamBuilder<DocumentSnapshot>(
        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('teams')
            .document((_teamName))
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');
          if (snapshot.data["goal"] != null) {
            return Text(
              "週" + snapshot.data["goal"].toString() + "km",
              style: TextStyle(
                fontSize: 40,
              ),
            );
          } else {
            return Text(
              "週0km",
              style: TextStyle(
                fontSize: 20,
              ),
            );
          }
        });
  }
}
