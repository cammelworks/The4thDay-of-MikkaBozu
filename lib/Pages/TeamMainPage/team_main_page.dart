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
    return Scaffold(
      appBar: AppBar(
        title: Text("チーム関連ページ"),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Row(
              children: <Widget>[
                Spacer(),
                Text("チーム検索"),
                Icon(Icons.search),
                Spacer()
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LookupTeamPage(),
                  )
              );
            },
          ),
          RaisedButton(
            child: Row(
              children: <Widget>[
                Spacer(),
                Text("チーム作成"),
                Icon(Icons.add),
                Spacer()
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamCreatePage(),
                  )
              );
            },
          ),
          Container(
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
                  return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => _buildListItem(
                          context, snapshot.data.documents[index]['team_name']));
                }),
          ),
        ],
      ),
      drawer: Sidemenu(),
    );
  }

  Widget _buildListItem(BuildContext context, String teamName) {
    return RaisedButton(
      child: Text(teamName),
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamPage(teamName),
            )
        );
      },
    );
  }
}