import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';

class Sidemenu extends StatelessWidget {
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
