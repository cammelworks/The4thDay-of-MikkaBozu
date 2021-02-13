import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class IconSelectPage extends StatefulWidget {
  final String title = 'アイコン選択';
  //コンストラクタ
  @override
  State<StatefulWidget> createState() => IconSelectPageState();
}

class IconSelectPageState extends State<IconSelectPage> {
  //コンストラクタ
  IconSelectPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getImages(),
          builder: (BuildContext context, AsyncSnapshot<Image> snapshot){
            if (snapshot.hasData) {
              return snapshot.data;
            } else {
              return Text("データが存在しません");
            }
          },
        ),
      ),
    );
  }

  Future<Image> getImages() async {
    String downloadURL = await firebase_storage.FirebaseStorage.
      instance.
      ref().
      child('icons/256/daruma.png').
      getDownloadURL() as String;
    print(downloadURL);
    Image img = new Image.network(downloadURL);
    return img;
  }
}