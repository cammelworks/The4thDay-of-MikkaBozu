// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'サインイン';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _EmailPasswordForm(),
          ],
        );
      }),
    );
  }

  // Example code for sign out.
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHidden = true;

  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Form(
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
            decoration: InputDecoration(
                labelText: 'パスワードを入れてね',
                suffixIcon: _isHidden ? IconButton(
                  onPressed: _toggleVisibility,
                  icon: Icon(Icons.visibility),
                ) : IconButton(
                  onPressed: _toggleVisibility,
                  icon: Icon(Icons.visibility_off),
                )
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return 'パスワード入れて（怒）';
              }
              return null;
            },
            obscureText: _isHidden,
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
                    if (_formKey.currentState.validate()) {
                      _signInWithEmailAndPassword();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  void _signInWithEmailAndPassword() async {
    FirebaseUser user;

    try {
      user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
    } on PlatformException {
      // メールやパスの入力がおかしかったらトーストを表示
      Fluttertoast.showToast(
        msg: 'パスワードかアドレスが間違ってるよ',
      );
    }

    if (user != null) {
      setState(() {
        //前のページに戻る
        Navigator.pop(context, user);
      });
    } else {}
  }
}
