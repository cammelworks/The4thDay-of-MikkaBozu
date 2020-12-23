import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/join_button.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamCreatePage/team_create_page.dart';

class LookupTeamPage extends StatefulWidget {
  final String title = 'チーム検索';

  @override
  State<StatefulWidget> createState() => LookupTeamPageState();
}

class LookupTeamPageState extends State<LookupTeamPage> {
  String _email = userData.userEmail;
  List<String> _joinedTeamList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameField = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 自分が所属しているチームを取得する
    _searchJoinedTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
//            height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
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
                                  print(_formKey.currentState.validate());
                                  if (_formKey.currentState.validate()) {
                                    // 再レンダリング
                                    setState(() {});
                                  }
                                  //キーボードを閉じる
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                              ),
                            ),
                            //エンターアイコンを変更
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (String value) async {
                              if (_formKey.currentState.validate())
                                setState(() {});
                              ;
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
                    ),
                    _showsearchResults(),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 64.0),
              child: ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                buttonColor: Colors.white,
                child: RaisedButton(
                  child: const Text('新規作成'),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onPressed: () async {
                    await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (context) => TeamCreatePage(),
                        ));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showsearchResults() {
    if (_teamNameField.text != "") {
      return FutureBuilder(
        future: _search(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
          final Size size = MediaQuery.of(context).size;
          if (snapshots.hasData) {
            if (snapshots.data.length == 0) {
              return Text("該当チームなし");
            } else {
              return Container(
                height: size.height * (2 / 3),
                child: Scrollbar(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshots.data.length,
                      itemBuilder: (context, int index) {
                        return Container(
                          child: Column(
                            children: [
                              Text(
                                "チーム名 " +
                                    snapshots.data[index].data["team_name"]
                                        .toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Visibility(
                                visible: snapshots
                                        .data[index].data["team_overview"] !=
                                    null,
                                child: Text(
                                  "概要 " +
                                      snapshots
                                          .data[index].data["team_overview"]
                                          .toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    snapshots.data[index].data["goal"] != null,
                                child: Text(
                                  "目標 " +
                                      snapshots.data[index].data["goal"]
                                          .toString() +
                                      "km",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              JoinButton(snapshots.data[index].data["team_name"]
                                  .toString()),
                            ],
                          ),
                        );
                      }),
                ),
              );
            }
          } else {
            return Text("検索中");
          }
        },
      );
    } else {
      return Container();
    }
  }

  Future<List<DocumentSnapshot>> _search() async {
    //結果を格納するリストを初期化する
    List<DocumentSnapshot> result = [];
    // 全チームを検索する
    QuerySnapshot docs =
        await Firestore.instance.collection("teams").getDocuments();
    // すでに参加しているチームをリストに格納する
    await docs.documents.forEach((doc) {
      if (_teamSearch(doc)) {
        result.add(doc);
      }
    });
    return result;
  }

  // 自分が所属しているチームを検索して配列に格納する
  void _searchJoinedTeam() async {
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

  bool _teamSearch(DocumentSnapshot snapshot) {
    // すでに参加していたらfalseを返す
    if (_joinedTeamList.contains(snapshot.data["team_name"].toString())) {
      return false;
    } else {
      // チーム名か概要に入力された文字列が含まれていたらtrueを返す
      if (snapshot.data["team_name"].toString().contains(_teamNameField.text)) {
        return true;
      } else if (snapshot.data["team_overview"] != null &&
          snapshot.data["team_overview"]
              .toString()
              .contains(_teamNameField.text)) {
        return true;
      }
      // ヒットなし
      else {
        return false;
      }
    }
  }
}
