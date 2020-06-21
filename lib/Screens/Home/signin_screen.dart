import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../register_page.dart';
import '../../signin_page.dart';



//コールバック関数を変数として定義
typedef UserCallback = void Function(FirebaseUser user);

class SigninScreen extends StatelessWidget {
  final UserCallback callback;
  //コンストラクタ
  SigninScreen(this.callback) : super();

  @override
  Widget build(BuildContext context) {
    print("start");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: Colors.white,
              child: RaisedButton(
                  child: const Text('登録'),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onPressed: () async {
                    //移動先のページから値を受け取る
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ));
                    callback(result);
                  }),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              buttonColor: Colors.white,
              child: RaisedButton(
                  child: const Text('サインイン'),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onPressed: () async {
                    //移動先のページから値を受け取る
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ));
                    callback(result);
                  }),
            ),
          ),
        ),
      ],
    );
    ;
  }
}
