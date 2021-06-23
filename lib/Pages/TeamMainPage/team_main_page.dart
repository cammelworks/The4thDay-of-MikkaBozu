import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/lookup_team_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/team_page.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class TeamMainPage extends StatefulWidget {
  Function _callback;
  TeamMainPage(this._callback);
  @override
  TeamMainPageState createState() => TeamMainPageState();
}

class TeamMainPageState extends State<TeamMainPage> {
  String _email = userData.userEmail;
  Function _callback;

  @override
  void initState() {
    _callback = widget._callback;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('チーム関連ページ'),
      ),
      body: SingleChildScrollView(
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
              return Scrollbar(
                isAlwaysShown: true,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) =>
                        _buildListItem(context, snapshot.data.documents[index]['team_name'] as String)),
              );
            }),
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
    // final Size size = MediaQuery.of(context).size;
    return Container(
      // margin: EdgeInsets.fromLTRB(size.width / 5, 16.0, size.width / 5, 0.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          0,
        ),
        child: RaisedButton(
          child: Card(
            child: Text(
              teamName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          onPressed: () async {
            await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (context) => TeamPage(teamName),
                ));
          },
        ),
      ),
      // child: ButtonTheme(
      //   minWidth: 200.0,
      //   height: 50.0,
      //   buttonColor: Colors.white,
      //   child: RaisedButton(
      //     child: Text(
      //       teamName,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //     shape: OutlineInputBorder(),
      //     onPressed: () async {
      //       await Navigator.push<dynamic>(
      //           context,
      //           MaterialPageRoute<dynamic>(
      //             builder: (context) => TeamPage(teamName),
      //           ));
      //     },
      //   ),
      // ),
    );
  }
}
