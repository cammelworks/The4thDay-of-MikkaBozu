// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'join_button.dart';

class LookupTeamPage extends StatefulWidget {
  String _email;
  //コンストラクタ
  LookupTeamPage(this._email);

  final String title = 'チーム検索';
  @override
  State<StatefulWidget> createState() => LookupTeamPageState(_email);
}

class LookupTeamPageState extends State<LookupTeamPage> {
  String _email;
  bool _showButton = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameField = TextEditingController();
  //コンストラクタ
  LookupTeamPageState(this._email);
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
            Form(
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
                          if (_formKey.currentState.validate()) {
                            _lookupTeam();
                          }
                          //キーボードを閉じる
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                    ),
                    //エンターアイコンを変更
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (String value) async {
                      if (_formKey.currentState.validate()) _lookupTeam();
                    },
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'チーム名を入力してください';
                      }
                      return null;
                    },
                  ),
                  Center(
                    child: showJoinButton(),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
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
        setState(() {
          _showButton = true;
        });
      } else {
        //すでに自分がチームに参加している
        Fluttertoast.showToast(
          msg: 'すでに参加しています。',
        );
      }
    } else {
      setState(() {
        _showButton = false;
      });
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

  Widget showJoinButton() {
    if (_showButton) {
      //登録ボタンの表示
      return JoinButton(_teamNameField.text, _email, () {});
    } else {
      //何も表示しない
      return null;
    }
  }
}
