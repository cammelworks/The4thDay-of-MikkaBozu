import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/lookup_team_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/team_page.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class TeamMainPage extends StatefulWidget {
  Function callback;
  TeamMainPage(this.callback);
  @override
  TeamMainPageState createState() => TeamMainPageState(callback);
}

class TeamMainPageState extends State<TeamMainPage> {
  String _email = userData.userEmail;
  Function callback;

  TeamMainPageState(this.callback);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'チーム関連ページ',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: size.height * (3 / 4),
              child: StreamBuilder<QuerySnapshot>(
                  //表示したいFirestoreの保存先を指定
                  stream: Firestore.instance.collection('users').document(_email).collection('teams').snapshots(),
                  //streamが更新されるたびに呼ばれる
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    //データが取れていない時の処理
                    if (!snapshot.hasData)
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    ;
                    return Scrollbar(
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) =>
                              _buildListItem(context, snapshot.data.documents[index]['team_name'] as String)),
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (context) => LookupTeamPage(),
              ));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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
        child: Stack(overflow: Overflow.visible, children: [
          RaisedButton(
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
              setState(() {});
              callback();
            },
          ),
          Positioned(
            top: -8,
            right: 40,
            child: Visibility(
              visible: userData.hasNewChat[teamName],
              child: Icon(
                Icons.brightness_1,
                color: Colors.red,
                size: 20,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
