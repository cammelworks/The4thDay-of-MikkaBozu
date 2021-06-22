import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverviewManager extends StatelessWidget {
  String _teamName;
  bool _isAdmin;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _overviewController = TextEditingController();

  OverviewManager(this._teamName, this._isAdmin);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '概要',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _teamName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            StreamBuilder(
                stream: Firestore.instance.collection('teams').document(_teamName).collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Text(snapshot.data.documents.length.toString() + 'メンバー');
                }),
          ],
        ),
        _showOverview(),
      ],
    );
  }

  Widget _showOverview() {
    //Firestoreから目標を取得して表示
    return StreamBuilder<DocumentSnapshot>(
        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance.collection('teams').document((_teamName)).snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData)
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          ;
          if (snapshot.data["team_overview"] != null) {
            return Row(
              children: <Widget>[
                Text(
                  snapshot.data["team_overview"].toString(),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Visibility(
                  visible: _isAdmin,
                  child: IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () async {
                        showDialog<dynamic>(
                          context: context,
                          builder: (context) {
                            return Form(
                              key: _formKey,
                              child: SimpleDialog(
                                title: Text("チーム概要の変更"),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: TextFormField(
                                      controller: _overviewController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: '変更する概要を入力してください',
                                      ),
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return '概要が入力されていません';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      FlatButton(
                                          child: Text("変更"),
                                          onPressed: () {
                                            if (_formKey.currentState.validate()) {
                                              Firestore.instance.collection('teams').document(_teamName).updateData(
                                                  <String, dynamic>{'team_overview': _overviewController.text});
                                              _overviewController.text = "";
                                              Navigator.pop(context);
                                            }
                                          }),
                                      FlatButton(
                                        child: Text("キャンセル"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
