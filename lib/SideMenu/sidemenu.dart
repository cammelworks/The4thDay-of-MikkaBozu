import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

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
          Row(
            children: [
              Center(child: Container(child: Text(userData.userEmail))),
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.grey,
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text("タイトル"),
                        children: [
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '変更するユーザー名を入力してください',
                            ),
                          ),
                          FlatButton(
                            child: Text("キャンセル"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text("変更"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Container(
            child: SignoutButton(),
          ),
        ],
      ),
    );
  }
}
