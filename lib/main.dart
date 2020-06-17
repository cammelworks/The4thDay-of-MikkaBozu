// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './Screens/Home/home_manager.dart';
import './Screens/Home/nav_drawer.dart';

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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  HomeManager _manager;

  @override
  void initState() {
    super.initState();

    // マネージャの初期化
    _manager = HomeManager(updateStateCallback: () {
      // ステート更新
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _manager.showButton());
  }
}
