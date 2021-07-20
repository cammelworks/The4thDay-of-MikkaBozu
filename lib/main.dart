import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.Dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the4thdayofmikkabozu/PageView/page_view.dart';
import 'package:the4thdayofmikkabozu/Pages/MyPage/signin_screen.dart';
import 'package:the4thdayofmikkabozu/permission.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as user_data;

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
      home: const MyHomePage(title: '三日坊主の四日目'),
      theme: ThemeData(primaryColor: const Color(0xff21426a)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final AudioPlayer _audioPlayer = AudioPlayer();
  File _audioFile;

  @override
  void initState() {
    super.initState();
    // 通知音の初期化
    initAudio();
    _firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {});
        // 通知音を鳴らす
        await _audioPlayer.play(_audioFile.path, isLocal: true);
        print('onMessage: $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: checkLoggedInPast(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data) {
                  return MyPageView();
                } else {
                  return SigninScreen();
                }
              }
            }));
  }

  //ログインの有無によって表示を変える関数
  Future<bool> checkLoggedInPast() async {
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

      // todo これいるかな？ 各変更のタイミングでしっかり受け渡しできてるなら消したいので要確認
      final userSnapshot = await Firestore.instance.collection('users').document(_user.email).get();

      String userName = 'Guest';
      if (userSnapshot.data['name'] != null) {
        userName = userSnapshot.data['name'].toString();
      }
      if (userSnapshot.data['icon_url'] != null) {
        user_data.iconUrl = userSnapshot.data['icon_url'].toString();
      }
      // end

      final userTeamsSnapshots =
          await Firestore.instance.collection('users').document(_user.email).collection('teams').getDocuments();

      for (final team in userTeamsSnapshots.documents) {
        final Timestamp lastVisitedTS = team.data['last_visited'] as Timestamp;
        final QuerySnapshot newChat = await Firestore.instance
            .collection('teams')
            .document(team.data['team_name'].toString())
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .getDocuments();
        if (newChat.documents.isEmpty) {
          //チームにチャットがない場合(絶対に未読にならない)
          user_data.hasNewChat[team.data['team_name'].toString()] = false;
          print('チームのチャットはまだ利用されていません');
        } else {
          //チームにチャットがある場合
          final Timestamp newChatTimeTS = newChat.documents[0].data['timestamp'] as Timestamp;
          if (lastVisitedTS == null) {
            //チームのチャットページを見たことがない場合(絶対に未読になる)
            user_data.hasNewChat[team.data['team_name'].toString()] = true;
            print('チームのチャットを見たことがありません');
          } else {
            final DateTime lastVisited = lastVisitedTS.toDate();
            final DateTime newChatTime = newChatTimeTS.toDate();
            //チャットページを最後に見た時間と最新のチャットの時間の比較
            if (lastVisited.compareTo(newChatTime) < 0) {
              print(team.data['team_name'].toString() + 'に未読のチャットがあります');
              user_data.hasNewChat[team.data['team_name'].toString()] = true;
            } else {
              print(team.data['team_name'].toString() + 'に未読のチャットはありません');
              user_data.hasNewChat[team.data['team_name'].toString()] = false;
            }
          }
        }
      }

      user_data.userName = userName;
      user_data.userEmail = _user.email;
      user_data.firebaseUser = _user;

      setState(() {});

      return true;
    } else {
      //初回起動 or サインアウト後
      return false;
    }
  }

  Future<void> initAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    // 通知音を保存するファイルの作成
    _audioFile = File('${dir.path}/notification.mp3');
    // 作成したファイルに書き込む
    await _audioFile.writeAsBytes((await loadAsset()).buffer.asUint8List());
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('sounds/notification.mp3');
  }
}
