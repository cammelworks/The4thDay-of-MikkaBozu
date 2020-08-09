import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/lookup_team_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamCreatePage/team_create_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/team_page.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class TeamMainPage extends StatefulWidget {
  @override
  TeamMainPageState createState() => TeamMainPageState();
}

class TeamMainPageState extends State<TeamMainPage> {
  String _email = userData.userEmail;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("チーム関連ページ"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin:
                EdgeInsets.fromLTRB(size.width / 4, 16.0, size.width / 4, 0.0),
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: Colors.white,
              child: RaisedButton(
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "チーム検索",
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(Icons.search),
                    Spacer()
                  ],
                ),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                onPressed: () async {
                  await Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (context) => LookupTeamPage(),
                      ));
                },
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.fromLTRB(size.width / 4, 16.0, size.width / 4, 0.0),
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: Colors.white,
              child: RaisedButton(
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "チーム作成",
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(Icons.add),
                    Spacer()
                  ],
                ),
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
          Container(
            height: size.height * (6 / 12),
            child: StreamBuilder<QuerySnapshot>(
                //表示したいFirestoreの保存先を指定
                stream: Firestore.instance
                    .collection('users')
                    .document(_email)
                    .collection('teams')
                    .snapshots(),
                //streamが更新されるたびに呼ばれる
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  //データが取れていない時の処理
                  if (!snapshot.hasData) return const Text('Loading...');
                  return Scrollbar(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildListItem(
                            context,
                            snapshot.data.documents[index]['team_name']
                                as String)),
                  );
                }),
          ),
        ],
      ),
      drawer: Sidemenu(),
    );
  }

  Widget _buildListItem(BuildContext context, String teamName) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.fromLTRB(size.width / 5, 16.0, size.width / 5, 0.0),
      child: ButtonTheme(
        minWidth: 200.0,
        height: 50.0,
        buttonColor: Colors.white,
        child: RaisedButton(
          child: Text(
            teamName,
            style: TextStyle(fontSize: 18),
          ),
          shape: OutlineInputBorder(),
          onPressed: () async {
            await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (context) => TeamPage(teamName),
                ));
          },
        ),
      ),
    );
  }
}
