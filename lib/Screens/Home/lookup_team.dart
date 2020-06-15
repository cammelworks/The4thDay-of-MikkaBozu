import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef TeamFoundCallback = void Function(String teamName);

class LookupTeam extends StatelessWidget {
  final TeamFoundCallback callback;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameField = TextEditingController();
  String _email;
  String _teamname;

  LookupTeam(this._email, this._teamname, this.callback) : super();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _teamNameField,
            decoration: InputDecoration(
              labelText: '参加したいチーム名を入力してください',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    _lookupTeam();
                  }
                  //キーボードを閉じる
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              ),
              hintText: _teamname,
            ),
            //エンターアイコンを変更
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (String value) async {
              if(_formKey.currentState.validate())
                _lookupTeam();
            },
            validator: (String value) {
              if (value.isEmpty) {
                return 'チーム名を入力してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  //チームを検索する
  void _lookupTeam() async {
    var docs = await Firestore.instance
        .collection("teams")
        .where("team_name", isEqualTo: _teamNameField.text)
        .getDocuments();
    //入力されたチーム名があればコールバック
    if (docs.documents.length != 0) {
      if (await _searchAlreadyJoin(docs.documents[0].documentID)) {
        callback(_teamNameField.text);
      } else {
        //すでに自分がチームに参加している
        Fluttertoast.showToast(
          msg: 'すでに参加しています。',
        );
      }
    } else {
      callback(null);
      Fluttertoast.showToast(
        msg: '存在しないチームです',
      );
    }
  }

  //すでに自分がチームに参加しているか調べる
  Future<bool> _searchAlreadyJoin(String teamName) async {
    var docs = await Firestore.instance
        .collection("teams")
        .document(teamName)
        .collection('users')
        .where("email", isEqualTo: _email)
        .getDocuments();
    if (docs.documents.length >= 1) {
      return false;
    } else {
      return true;
    }
  }
}
