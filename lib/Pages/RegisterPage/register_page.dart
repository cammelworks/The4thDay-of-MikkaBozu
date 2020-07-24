import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the4thdayofmikkabozu/main.dart';

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
  bool _isHidden = true;

  void _toggleVisibility(){
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
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'アドレスを入力してください'),
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
                  return 'パスワードが入力されていません';
                } else if (validateIncludeNumber(value)) {
                  return '数字も含めてください';
                } else if (!validateLength(value)) {
                  return '8文字以上にしてください';
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
    //端末のデータにアクセスするための変数
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
          msg: 'そのアドレスはすでに使用されています',
        );
      }
    }

    if (user != null) {
      //emailとパスワードを端末に保存
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      print(prefs.getString('email'));
      print(prefs.getString('password'));

      setState(() {
        //Firestoreにemailをpush
        Firestore.instance
            .collection('users')
            .document(user.email)
            .setData(<String, dynamic>{'email': user.email});
      });
      await Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => MyHomePage(),
          ),
          (_) => false
      );
    }
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
