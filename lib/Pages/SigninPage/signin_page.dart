import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'サインイン';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: 'アドレスを入力してください'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'アドレスが入力されていません';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'パスワードを入力してください',
                        suffixIcon: _isHidden
                            ? IconButton(
                                onPressed: _toggleVisibility,
                                icon: Icon(Icons.visibility),
                              )
                            : IconButton(
                                onPressed: _toggleVisibility,
                                icon: Icon(Icons.visibility_off),
                              )),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'パスワードが入力されていません';
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
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
            ),
          ],
        );
      }),
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
    //端末のデータにアクセスするための変数
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
    } on PlatformException {
      // メールやパスの入力がおかしかったらトーストを表示
      Fluttertoast.showToast(
        msg: 'パスワードかアドレスが間違っています',
      );
    }

    if (user != null) {
      //emailとパスワードを端末に保存
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      print(prefs.getString('email'));
      print(prefs.getString('password'));

      setState(() {
        //前のページに戻る
        Navigator.pop(context, user);
      });
    } else {}
  }
}