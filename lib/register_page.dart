// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  final String title = 'アカウント登録';
  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'アドレスを入れてね'),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'アドレス入れて（怒）';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'パスワードを入れてね'),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'パスワード入れて（怒）';
                } else if (validateIncludeNumber(value)) {
                  return '数字も混ぜてね';
                } else if (!validateLength(value)) {
                  return '8文字以上にしてね';
                }
                return null;
              },
              obscureText: true,
            ),
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
                        if (_formKey.currentState.validate()) {
                          _register();
                        }
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code for registration.
  void _register() async {
    FirebaseUser user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
    } on PlatformException catch (e) {
      //メールアドレスが使われていた場合実行
      if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
        // トーストを表示
        Fluttertoast.showToast(
          msg: 'そのアドレスはもう使われてるよ',
        );
      }
    }

    if (user != null) {
      setState(() {
        //Firestoreにemailをpush
        Firestore.instance
            .collection('user')
            .document()
            .setData({'email': user.email});
        //前のページに戻る
        Navigator.pop(context, user);
      });
    } else {}
  }

  bool validateIncludeNumber(String value) {
    String pattern = r'^\D+$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateLength(String value) {
    String pattern = r'^.{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }
}
