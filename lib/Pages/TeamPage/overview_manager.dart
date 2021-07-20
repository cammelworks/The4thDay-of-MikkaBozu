import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverviewManager extends StatelessWidget {
  final String _teamName;
  final bool _isAdmin;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _overviewController = TextEditingController();

  OverviewManager(this._teamName, this._isAdmin);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 8, 24, 16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '概要',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Visibility(
                  visible: _isAdmin,
                  child: OutlineButton(
                      color: Theme.of(context).primaryColor,
                      shape: const StadiumBorder(),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            size: 16,
                          ),
                          const Text('編集')
                        ],
                      ),
                      onPressed: () async {
                        showDialog<dynamic>(
                          context: context,
                          builder: (context) {
                            return Form(
                              key: _formKey,
                              child: SimpleDialog(
                                title: const Text('チーム概要の変更'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _overviewController,
                                      decoration: const InputDecoration(
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
                                          child: const Text('変更'),
                                          onPressed: () {
                                            if (_formKey.currentState.validate()) {
                                              Firestore.instance.collection('teams').document(_teamName).updateData(
                                                  <String, dynamic>{'team_overview': _overviewController.text});
                                              _overviewController.text = '';
                                              Navigator.pop(context);
                                            }
                                          }),
                                      FlatButton(
                                        child: const Text('キャンセル'),
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
            ),
            Center(
              child: Column(
                children: <Widget>[
                  // // チームアイコンを実装したときにコメント外して使ってください
                  // Container(
                  //   width: 100,
                  //   height: 100,
                  //   clipBehavior: Clip.antiAlias,
                  //   decoration: const BoxDecoration(
                  //     shape: BoxShape.circle,
                  //   ),
                  // // ここに画像を指定
                  //   child: Image.network(
                  //     'https://picsum.photos/seed/566/600',
                  //   ),
                  // ),
                  Text(
                    _teamName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  StreamBuilder(
                      stream:
                          Firestore.instance.collection('teams').document(_teamName).collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Text(snapshot.data.documents.length.toString() + 'メンバー');
                      }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
              child: StreamBuilder(
                  //表示したいFirestoreの保存先を指定
                  stream: Firestore.instance.collection('teams').document(_teamName).snapshots(),
                  //streamが更新されるたびに呼ばれる
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    //データが取れていない時の処理
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data['team_overview'] != null) {
                      return Text(
                        snapshot.data['team_overview'].toString(),
                      );
                    } else {
                      return const Text('このチームの概要がありません！');
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
