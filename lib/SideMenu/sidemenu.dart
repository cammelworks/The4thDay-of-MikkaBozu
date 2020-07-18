import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/lookup_team_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamcreatePage/team_create_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/team_page.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/my_page.dart';

class Sidemenu extends StatelessWidget {
  String _email = userData.userEmail;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.pinkAccent,
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('images/bouzu.png'))),
          ),
          ListTile(
            dense: true,
            title: Text('MYPAGE'),
            onTap: () async => {
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyPage(),
                )),
            },
          ),
          ListTile(
            dense: true,
            title: Text(
              'TEAM',
            ),
            trailing: Wrap(spacing: -16, children: <Widget>[
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    //チーム作成ページに移動
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LookupTeamPage(),
                        ));
                  }),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    //チーム作成ページに移動
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamCreatePage(_email),
                        ));
                  }),
            ]),
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
                          context, snapshot.data.documents[index]));
                }),
          ),
          Container(
            child: SignoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Container(
        height: 34,
        child: ListTile(
          dense: true,
          title: Text(document['team_name']),
          onTap: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamPage(document['team_name']),
                )),
          },
        ),
      ),
    );
  }
}
