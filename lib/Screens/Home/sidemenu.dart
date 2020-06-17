import 'package:flutter/material.dart';

import 'team_create_button.dart';

import '../../lookup_team_page.dart';

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
            trailing:IconButton(icon: Icon(Icons.search),
              onPressed: () async {
                //チーム作成ページに移動
                final result = await Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => LookupTeamPage(_email),
                ));
                },
            ),
          ),
          TeamCreateButton(_email),
        ],
      ),
    );
  }
}
