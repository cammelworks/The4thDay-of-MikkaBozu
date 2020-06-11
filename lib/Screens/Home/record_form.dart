import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordForm extends StatelessWidget {
  String _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recordField = TextEditingController();

  RecordForm(this._email);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
        child:Column(
          children: <Widget>[
            TextFormField(
              controller: _recordField,
              decoration: InputDecoration(
                labelText: '走った距離を入力してください',
                suffixIcon: IconButton(
                  icon: Icon(Icons.directions_run),
                  onPressed: () async {
                    if(_formKey.currentState.validate())
                      _pushRecord();
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              //キーボードのエンターを押すとFireStoreに送信
              onFieldSubmitted: (String value) async {
                if(_formKey.currentState.validate())
                  _pushRecord();
              },
              validator: (String value) {
                if (value.isEmpty) {
                  return '距離が入力されていません';
                }
                return null;
              },
            ),
          ],
        ),
    );
  }

  void _pushRecord() async {
    //自分のEmailに紐づくドキュメントを取得
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
            .collection('records')
            .document()
            .setData({'distance': _recordField.text, 'timestamp': Timestamp.now()});
      } else {
        print("Not Found");
      }
    });
  }
}
