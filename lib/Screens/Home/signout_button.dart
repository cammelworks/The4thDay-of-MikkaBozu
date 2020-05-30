import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

//コールバック関数を変数として定義
typedef UserCallback = void Function(FirebaseUser user);

class SignoutButton extends StatelessWidget {
  FirebaseAuth _auth;
  String _email;
  final UserCallback callback;

  SignoutButton(this._auth, this._email, this.callback) : super();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: ButtonTheme(
          minWidth: 200.0,
          height: 50.0,
          buttonColor: Colors.white,
          child: RaisedButton(
              child: const Text('サインアウト'),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              onPressed: () async {
                signOut();
                final String email = _email;
                // トーストを表示
                Fluttertoast.showToast(
                  msg: email + 'はサインアウトしました．',
                );
//                    setState(() {
//                      user = null;
//                    });
                //ユーザがサインアウトしたことをコールバック
                callback(null);
              }),
        ),
      ),
    );
  }

  //サインアウトをする関数
  void signOut() async {
    await _auth.signOut();
  }
}
