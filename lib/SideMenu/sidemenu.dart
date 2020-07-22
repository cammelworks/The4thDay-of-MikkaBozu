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
            decoration: BoxDecoration(
                color: Colors.pinkAccent,
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('images/bouzu.png'))),
          ),
          Container(
            child: SignoutButton(),
          ),
        ],
      ),
    );
  }


}
