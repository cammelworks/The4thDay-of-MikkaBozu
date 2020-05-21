// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './register_page.dart';
import './signin_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '三日坊主の四日目',
      home: MyHomePage(title: '三日坊主の四日目'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(100.0, 16.0, 16.0, 0.0),
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
                    user = result;
                    print(result.email);
                  }),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(100.0, 16.0, 16.0, 0.0),
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
                    user = result;
                    print(result.email);
                  }),
            ),
          ),
//          Container(
//            child: RaisedButton(
//                child: const Text('登録'),
//                onPressed: () async {
//                  //移動先のページから値を受け取る
//                  final result = await Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => RegisterPage(),
//                      ));
//                  user = result;
//                  print(result.email);
//                }),
//            padding: const EdgeInsets.all(16),
//            alignment: Alignment.center,
//          ),
//          Container(
//            child: RaisedButton(
//                child: const Text('サインイン'),
//                onPressed: () async {
//                  //移動先のページから値を受け取る
//                  final result = await Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => SignInPage(),
//                      ));
//                  user = result;
//                  print(result.email);
//                }),
//            padding: const EdgeInsets.all(16),
//            alignment: Alignment.center,
//          ),
        ],
      ),
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
