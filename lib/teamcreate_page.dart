// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamCreatePage extends StatefulWidget {
  String _email;
  //コンストラクタ
  TeamCreatePage(this._email);

  final String title = 'チーム作成';
  @override
  State<StatefulWidget> createState() => TeamCreatePageState(_email);
}

class TeamCreatePageState extends State<TeamCreatePage> {
  String _email;
  //コンストラクタ
  TeamCreatePageState(this._email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _TeamForm(_email),
          ],
        );
      }),
    );
  }
}

class _TeamForm extends StatefulWidget {
  String _email;
  //コンストラクタ
  _TeamForm(this._email);
  @override
  State<StatefulWidget> createState() => _TeamFormState(_email);
}

class _TeamFormState extends State<_TeamForm> {
  String _email;
  //コンストラクタ
  _TeamFormState(this._email);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'チーム名を入れてね'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'チーム名を入れて（怒）';
              }
              return null;
            },
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
              child: ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  child: const Text('作成'),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate() && await checkUniqueTeamName(_nameController.text)) {
                      createTeam(_email);
                      updateDataUserData(_email);
                      Navigator.pop(context);
                    }
                    else {
                      print('failed');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //チームを作成する関数
  void createTeam(String email) {
    Firestore.instance
        .collection('teams')
        .document(_nameController.text)
        .setData({'team_name': _nameController.text});

    Firestore.instance
        .collection('teams')
        .document(_nameController.text)
        .collection('users')
        .document()
        .setData({'email': email});
  }

  //ユーザデータにチーム名を追加する関数
  void updateDataUserData(String email) {
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
            .collection('teams')
            .document()
            .setData({'team_name': _nameController.text});
      } else {
        print("Not Found");
      }
    });
  }
  
  Future<bool> checkUniqueTeamName(String candidateName) async {
    bool flag = true;
    var docs = await Firestore.instance.collection('teams').getDocuments();
    docs.documents.forEach((var doc){
      if (candidateName == doc['team_name']){
        flag = false;
      }
    });
    return flag;
  }
}