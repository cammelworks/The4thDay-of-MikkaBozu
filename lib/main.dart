// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './register_page.dart';
import './signin_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
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
        body: Container(
          child: showButton(),
        ));
  }

  Widget showButton() {
    if (user == null) {
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
                      user = result;
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
                      user = result;
                    }),
              ),
            ),
          ),
        ],
      );
    } else {
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
                    child: const Text('チーム作成'),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    onPressed: () async {
                      _createTeam(); //チームの作成
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
                    child: const Text('サインアウト'),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    onPressed: () async {
                      _signOut();
                      final String email = user.email;
                      // トーストを表示
                      Fluttertoast.showToast(
                        msg: email + 'はサインアウトしました．',
                      );
                      setState(() {
                        user = null;
                      });
                    }),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text(user.email),
            ),
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              child: getTeamID(),
            ),
          ),
        ],
      );
    }
  }

  //チームを作成する関数
  void _createTeam() {
    Firestore.instance
        .collection('teams')
        .document()
        .setData({'email': user.email});
  }

  void _signOut() async {
    await _auth.signOut();
  }

  //チームIDを取得する関数
  Widget getTeamID() {
    return StreamBuilder<QuerySnapshot>(

        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection("teams")
            .where("email", isEqualTo: user.email)
            .snapshots(),

        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');

//          return Text(snapshot.data.documents[0].documentID);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: const EdgeInsets.all(6),
                alignment: Alignment.center,
                child: Text(
                  snapshot.data.documents[index].documentID,
                ),
              );
            },
          );
        });
  }
}
