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
              Expanded(
                child: Container(),
              ),
              Container(child: Text(userData.userEmail)),
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.grey,
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text("ユーザ名変更"),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '変更するユーザ名を入力してください',
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                child: Text("キャンセル"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              FlatButton(
                                child: Text("変更"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: Container(),
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
