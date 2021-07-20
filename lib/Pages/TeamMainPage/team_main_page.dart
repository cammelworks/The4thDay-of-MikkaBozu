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
        title: const Text('チーム一覧'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          //表示したいFirestoreの保存先を指定
          stream: Firestore.instance.collection('users').document(_email).collection('teams').snapshots(),
          //streamが更新されるたびに呼ばれる
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //データが取れていない時の処理
            if (!snapshot.hasData)
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            return ListView.builder(
                itemCount: snapshot.data.documents.length + 1,
                itemBuilder: (context, index) {
                  // リストの最後にチームの追加ボタンを設ける
                  if (index == snapshot.data.documents.length) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (context) => LookupTeamPage(),
                            ));
                        setState(() {});
                      },
                      child: Card(
                        child: Container(
                          height: 104,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildListItem(context, snapshot.data.documents[index]['team_name'] as String);
                });
          }),
      drawer: Sidemenu(),
    );
  }

  Widget _buildListItem(BuildContext context, String teamName) {
    return Container(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (context) => TeamPage(teamName),
              ));
        },
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    // // ！チームアイコンを表示(後々の実装のため)
                    // leading: Padding(
                    //   padding: const EdgeInsets.all(6.0),
                    //   child: Container(
                    //     clipBehavior: Clip.antiAlias,
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //     ),
                    //     // ！後々アイコンが導入できたらここに画像のリンクもしくは画像を差し替えてください
                    //     child: Image.network(
                    //       'https://picsum.photos/seed/566/600',
                    //     ),
                    //   ),
                    // ),
                    title: Text(
                      teamName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    subtitle: StreamBuilder(
                        stream: Firestore.instance.collection('teams').document(teamName).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Text(snapshot.data['team_overview'].toString());
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.flag,
                                  color: Theme.of(context).unselectedWidgetColor,
                                ),
                                StreamBuilder(
                                  stream: Firestore.instance.collection('teams').document(teamName).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return Text(
                                      '週' + snapshot.data['goal'].toString() + 'km',
                                      style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.people,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                              StreamBuilder(
                                stream: Firestore.instance.collection('teams').document(teamName).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  return Text(
                                    snapshot.data['user_num'].toString() + 'メンバー',
                                    style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 20,
              child: Visibility(
                visible: userData.hasNewChat[teamName],
                child: Icon(
                  Icons.brightness_1,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
