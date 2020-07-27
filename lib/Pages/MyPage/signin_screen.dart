import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/RegisterPage/register_page.dart';
import 'package:the4thdayofmikkabozu/Pages/SigninPage/signin_page.dart';

class SigninScreen extends StatefulWidget{
  final String title = '三日坊主の四日目';
  @override
  State<StatefulWidget> createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
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
                      await Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => RegisterPage(),
                          ));
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
                      await Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => SignInPage(),
                          ));
                    }),
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
