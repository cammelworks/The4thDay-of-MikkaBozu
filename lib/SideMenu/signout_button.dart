import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the4thdayofmikkabozu/main.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class SignoutButton extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = userData.userEmail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ButtonTheme(
          minWidth: 200.0,
          height: 50.0,
          buttonColor: Colors.white,
          child: RaisedButton(
              child: const Text('サインアウト'),
              // shape: OutlineInputBorder(
              //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
              // ),
              shape: StadiumBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: () async {
                await signOut();
                final String email = _email;
                // トーストを表示
                Fluttertoast.showToast(
                  msg: email + 'はサインアウトしました',
                );
                await Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (context) => MyHomePage(),
                    ),
                    (_) => false);
              }),
        ),
      ),
    );
  }

  //サインアウトをする関数
  void signOut() async {
    await _auth.signOut();
    //端末データからemailとパスワードを削除する
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("email");
    await prefs.remove("password");
  }
}
