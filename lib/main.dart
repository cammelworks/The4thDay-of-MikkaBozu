import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the4thdayofmikkabozu/PageView/page_view.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/signin_screen.dart';
import 'package:the4thdayofmikkabozu/permission.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user = null;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message;
  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _message = "onMessage: $message";
        });
        print("onMessage: $message");
      },

      /// 省略
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: showButton(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return MyPageView();
        } else if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && !snapshot.data) {
          return SigninScreen();
        }
      },
    ));
  }

  //ログインの有無によって表示を変える関数
  Future<bool> showButton() async {
    //端末のデータにアクセスするための変数
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //位置情報の許可が出ているか確認する
    Permission().checkPermission();

    if (_user != null) {
      return true;
    } else if (prefs.getString('password') != null) {
      //自動ログイン
      _user = (await _auth.signInWithEmailAndPassword(
        email: prefs.getString('email'),
        password: prefs.getString('password'),
      ))
          .user;

      var snapshot = await Firestore.instance.collection('users').document(_user.email).get();

      String userName = "Guest";
      if (snapshot.data['name'] != null) {
        userName = snapshot.data['name'].toString();
      }
      if (snapshot.data['icon_url'] != null) {
        userData.iconUrl = snapshot.data['icon_url'].toString();
      }
      userData.userName = userName;
      userData.userEmail = _user.email;
      userData.firebaseUser = _user;
      return true;
    } else {
      //初回起動 or サインアウト後
      return false;
    }
  }
}
