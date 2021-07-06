import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as user_data;

class TeamCreatePage extends StatefulWidget {
  final String title = 'チーム作成';

  @override
  State<StatefulWidget> createState() => TeamCreatePageState();
}

class TeamCreatePageState extends State<TeamCreatePage> {
  final String _email = user_data.userEmail;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'チーム名を入力してください'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '登録にはチーム名が必要です';
                      } else if (value.length >= 19) {
                        return 'チーム名が長すぎます';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _overviewController,
                    decoration: const InputDecoration(labelText: 'チームの概要を入力してください'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '登録にはチームの概要が必要です';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'チームの目標を入力してください'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '登録にはチームの目標が必要です';
                      } else if (_goalController.text.contains(',')) {
                        return '目標に","を含めないでください';
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
                          shape: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (await checkUniqueTeamName(_nameController.text)) {
                                createTeam();
                                updateDataUserData();
                                // hasNewChatの辞書に登録する
                                user_data.hasNewChat[_nameController.text] = false;
                                // 2ページ前に戻る
                                int count = 0;
                                Navigator.of(context).popUntil((_) => count++ >= 2);
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'すでに使用されています',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //チームを作成する関数
  void createTeam() {
    Firestore.instance.collection('teams').document(_nameController.text).setData(<String, dynamic>{
      'team_name': _nameController.text,
      'goal': int.parse(_goalController.text),
      'team_overview': _overviewController.text,
      'user_num': 1,
      'admin': _email,
    });

    Firestore.instance
        .collection('teams')
        .document(_nameController.text)
        .collection('users')
        .document(_email)
        .setData(<String, dynamic>{'email': _email});
  }

  //ユーザデータにチーム名を追加する関数
  void updateDataUserData() {
    Firestore.instance
        .collection('users')
        .document(_email)
        .collection('teams')
        .document(_nameController.text)
        .setData(<String, dynamic>{
      'goal': int.parse(_goalController.text),
      'last_visited': Timestamp.now(),
      'team_name': _nameController.text,
      'team_overview': _overviewController.text,
    });
  }

  Future<bool> checkUniqueTeamName(String candidateName) async {
    final docs =
        await Firestore.instance.collection('teams').where('team_name', isEqualTo: candidateName).getDocuments();
    if (docs.documents.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
