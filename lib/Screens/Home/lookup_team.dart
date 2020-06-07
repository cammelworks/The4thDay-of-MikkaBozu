import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef TeamFoundCallback = void Function(bool teamFound);

class LookupTeam extends StatelessWidget{
  final TeamFoundCallback callback;
  final TextEditingController _teamName = TextEditingController();

  LookupTeam(this.callback) : super();

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        TextFormField(
          controller: _teamName,
          decoration: InputDecoration(labelText: '参加したいチーム名を入れてね',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _sadfe,
              )),
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

  void _sadfe() async{
    var docs = await Firestore.instance
        .collection("teams")
        .where("team_name", isEqualTo: _teamName.text)
        .getDocuments();
    //入力されたチーム名があればコールバック
    if(docs.documents.length != 0){
      callback(true);
    }
  }


}