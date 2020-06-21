import 'package:flutter/material.dart';

import '../../LookupTeamPage/lookup_team_page.dart';
import '../../TeamcreatePage/team_create_page.dart';

class Sidemenu extends StatelessWidget {
  String _email;
  Sidemenu(this._email);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
            title: Text('MYPAGE'),
            onTap: () => {},
          ),
          ListTile(
            title: Text('TEAM'),
            trailing: Wrap(
              spacing: -16,
              children: <Widget>[
                IconButton(icon: Icon(Icons.search),
                onPressed: () async {
                    //チーム作成ページに移動
                  final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => LookupTeamPage(_email),
                  ));
                  }),
                  IconButton(icon: Icon(Icons.add),
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
          ],
        ),
      );
  }
}
