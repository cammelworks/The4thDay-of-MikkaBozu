import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

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
                    decoration:
                        const InputDecoration(labelText: 'チーム名を入力してください'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '登録にはチーム名が必要です';
                      } else if(value.length < 4){
                        return 'チーム名が短すぎます';
                      } else if(value.length > 20){
                        return 'チーム名が長すぎます';
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (await checkUniqueTeamName(
                                  _nameController.text)) {
                                createTeam(_email);
                                updateDataUserData(_email);
                                Navigator.pop(context);
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
        .document(email)
        .setData({'email': email});
  }

  //ユーザデータにチーム名を追加する関数
  void updateDataUserData(String email) {
    //自分のEmailに紐づくドキュメントを取得
    getData() async {
      return await Firestore.instance.collection('users').document(_email);
    }

    getData().then((val) {
      //データの更新
      if (val != null) {
        String userDocId = val.documentID;
        Firestore.instance
            .collection('users')
            .document(userDocId)
            .collection('teams')
            .document(_nameController.text)
            .setData({'team_name': _nameController.text});
      } else {
        print("Not Found");
      }
    });
  }

  Future<bool> checkUniqueTeamName(String candidateName) async {
    var docs = await Firestore.instance
        .collection("teams")
        .where("team_name", isEqualTo: candidateName)
        .getDocuments();
    if (docs.documents.length == 0) {
      return true;
    } else {
      return false;
    }
  }
}
