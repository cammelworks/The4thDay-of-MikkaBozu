import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalManager extends StatelessWidget{
  String _teamName;

  GoalManager(this._teamName);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _showGoal(),
      trailing: IconButton(icon: Icon(Icons.search),
          onPressed: () async {
            //目標変更
            showPickerNumber(context);
          }),
    );
  }

  Widget _showGoal(){
    //Firestoreから目標を取得して表示
  }

  showPickerNumber(BuildContext context) {
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
          var goal = values[0] * 10 + values[1];
          print(goal);
          _setGoal(goal);
        }).showDialog(context);
  }

  void _setGoal(int goal){
    //Firebaseのteamsに目標を設定する
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .updateData({'goal': goal});
  }

}