import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class IconSelectPage extends StatefulWidget {
  final String title = 'アイコン選択';
  //コンストラクタ
  @override
  State<StatefulWidget> createState() => IconSelectPageState();
}

class IconSelectPageState extends State<IconSelectPage> {
  final List<String> iconsName =
    ['daruma', 'heddohon', 'jitensya', 'kaba', 'neko', 'niku', 'ninjin', 'niwatori', 'onigiri', 'ookami'];
  //コンストラクタ
  IconSelectPageState();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getImages(size),
          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
            if (snapshot.hasData) {
              return Center(
                // 一覧表示
                child: Wrap(
                    children: snapshot.data
                ),
              );
            } else {
              return Container(
                height: size.height,
                width: size.width,
                child: Center(
                    child:CircularProgressIndicator()
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Widget>> getImages(Size size) async {
    var imagesList = List<Widget>();
    await Future.forEach(iconsName, (String element) async {
      String downloadURL = await firebase_storage.FirebaseStorage.
        instance.ref().child('icons/256/$element.png').
        getDownloadURL() as String;
      Image img = new Image.network(downloadURL);

      imagesList.add(
        new IconButton(
          onPressed: () async{
            // ダイアログを表示
            showDialog<dynamic>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('このアイコンに登録しますか？'),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("はい"),
                        onPressed: () {
                          registerIcon(downloadURL);
                          // 2ページ戻る
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        }),
                    FlatButton(
                      child: Text("キャンセル"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
            );
            print(downloadURL);
          },
          icon: img,
          iconSize: size.width / 4,
        )
      );
    });
    return imagesList;
  }

  void registerIcon(String downloadURL){
    Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .updateData(<String, String>{
          'icon_url': downloadURL
        });
    userData.iconUrl = downloadURL;
  }
}