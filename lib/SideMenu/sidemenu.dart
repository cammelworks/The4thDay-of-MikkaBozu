import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class Sidemenu extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SidemenuState();
}

class SidemenuState extends State<Sidemenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
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
              Container(child: Text(userData.userName)),
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.grey,
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return Form(
                        key: _formKey,
                        child: SimpleDialog(
                          title: Text("ユーザ名変更"),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                controller: _userNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '変更するユーザ名を入力してください',
                                ),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'ユーザ名が入力されていません';
                                  }
                                  return null;
                                },
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
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      Firestore.instance
                                          .collection('users')
                                          .document(userData.userEmail)
                                          .updateData(<String, dynamic>{
                                        'name': _userNameController.text
                                      });
                                      userData.userName = _userNameController.text;
                                      _userNameController.text = "";
                                      setState(() {

                                      });
                                      Navigator.pop(context);
                                    }
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),
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
