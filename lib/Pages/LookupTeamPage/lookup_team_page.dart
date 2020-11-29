import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/join_button.dart';

class LookupTeamPage extends StatefulWidget {
  final String title = 'チーム検索';

  @override
  State<StatefulWidget> createState() => LookupTeamPageState();
}

class LookupTeamPageState extends State<LookupTeamPage> {
  String _email = userData.userEmail;
  bool _showButton = false;
  String _docmentID = "aaaaaaaa";
  List<String> _joinedTeamList;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameField = TextEditingController();

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
                            addJoinedTeam();
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
                  if(_teamNameField.text != "")
                    showAllTeams(),
                  Container(
                    child: showOverview(),
                  ),
//                  Center(
//                    child: showJoinButton(),
//                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget showAllTeams() {
    return StreamBuilder<QuerySnapshot>(
      //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection("teams")
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');

          return Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, int index) {
                return GestureDetector(
                  child: teamSearch(index, snapshot)? Container(
                    child: Column(
                      children: [
                        Text(
                          "チーム名 " + snapshot.data.documents[index]["team_name"].toString(),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "概要 " + snapshot.data.documents[index]["team_overview"].toString(),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "目標 " + snapshot.data.documents[index]["goal"].toString() + "km",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        JoinButton(snapshot.data.documents[index].documentID),
                      ],
                    ),
                  ) : Container(),
                );
              },
            ),
          );
        });
  }

  //チームを検索する
  void _lookupTeam() async {
    var docs = await Firestore.instance
        .collection("teams")
//        .where("team_name", isEqualTo: _teamNameField.text)
        .getDocuments();
    //入力されたチーム名があればコールバック
    if (docs.documents.length != 0) {
      if (await _searchAlreadyJoin(docs.documents[0].documentID)) {
        setState(() {
          _showButton = true;
          _docmentID = docs.documents[0].documentID;
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
        _docmentID = "";
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

  Widget showOverview(){
    return StreamBuilder<DocumentSnapshot>(
      //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('teams')
            .document((_docmentID))
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');
          else if (snapshot.data.exists){
            if (snapshot.data["team_overview"] != null) {
              //検索結果の表示
              return Container(
                child: Column(
                  children: [
                    Text(
                      "チーム名 " + snapshot.data["team_name"].toString(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "概要 " + snapshot.data["team_overview"].toString(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "目標 " + snapshot.data["goal"].toString() + "km",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            }else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }

  Widget showJoinButton() {
    if (_showButton) {
      //登録ボタンの表示
      return JoinButton(_teamNameField.text);
    } else {
      //何も表示しない
      return null;
    }
  }

  void addJoinedTeam() async {
    _joinedTeamList = [];
    var docs = await Firestore.instance
        .collection('users')
        .document(_email)
        .collection("teams")
        .getDocuments();
    docs.documents.forEach((var document) {
      _joinedTeamList.add(document.data["team_name"].toString());
    });
  }

  bool teamSearch(int index, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (_joinedTeamList.contains(snapshot.data.documents[index].data["team_name"].toString())) {
      return false;
    }
    else {
      if (snapshot.data.documents[index].data["team_name"].toString().contains(
          _teamNameField.text) ||
          snapshot.data.documents[index].data["team_overview"]
              .toString()
              .contains(_teamNameField.text)) {
        return true;
      }
      else {
        return false;
      }
    }
  }
}
