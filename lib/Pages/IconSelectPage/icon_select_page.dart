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
  final List<String> iconsName =
    ['daruma', 'heddohon', 'jitensya', 'kaba', 'neko', 'niku', 'ninjin', 'niwatori', 'onigiri', 'ookami'];
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
          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
            if (snapshot.hasData) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.data
              );
            } else {
              return Text("データが存在しません");
            }
          },
        ),
      ),
    );
  }

  Future<List<Widget>> getImages() async {
    var images = List<Widget>();
    await Future.forEach(iconsName, (String element) async {
      String downloadURL = await firebase_storage.FirebaseStorage.
        instance.ref().child('icons/256/$element.png').
        getDownloadURL() as String;
      Image img = new Image.network(downloadURL);
      images.add(
        new IconButton(
          onPressed: (){
            // ダイアログを表示
            print(downloadURL);
          },
          icon: img,
        )
      );
    });
    return images;
  }

  //Container(
//  button(
//    image: icon
//    onPressed: Dialog(
//      onPressed: firestoreに追加
//    )
//  )
// )
}