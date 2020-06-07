import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef TeamFoundCallback = void Function(String teamName);

class LookupTeam extends StatelessWidget{
  final TeamFoundCallback callback;
  final TextEditingController _teamNameField = TextEditingController();
  String _teamname;

  LookupTeam(this._teamname, this.callback) : super();

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        TextFormField(
          controller: _teamNameField,
          decoration: InputDecoration(labelText: '参加したいチーム名を入れてね',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _lookup_team,
              ),
              hintText: _teamname,
          ),

          validator: (String value) {
            if (value.isEmpty) {
              return 'アドレス入れて（怒）';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _lookup_team() async{
    var docs = await Firestore.instance
        .collection("teams")
        .where("team_name", isEqualTo: _teamNameField.text)
        .getDocuments();
    //入力されたチーム名があればコールバック
    if(docs.documents.length != 0){
      callback(_teamNameField.text);
    } else {
      callback(null);
      Fluttertoast.showToast(
        msg: 'そんなチームないよ',
      );
    }
  }


}