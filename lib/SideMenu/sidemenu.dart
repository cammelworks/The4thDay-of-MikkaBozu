import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the4thdayofmikkabozu/Pages/IconSelectPage/icon_select_page.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class Sidemenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SidemenuState();
}

class SidemenuState extends State<Sidemenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  File file;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: SafeArea(
              child: Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Center(
                    child: Stack(children: <Widget>[
                      showIcon(),
                      Positioned(
                        right: -20,
                        bottom: -4,
                        child: RaisedButton(
                          shape: CircleBorder(),
                          color: Colors.grey,
                          onPressed: () async {
                            await Navigator.push<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (context) => IconSelectPage(),
                                ));
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(child: Text(userData.userName)),
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.grey,
                onPressed: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return Form(
                        key: _formKey,
                        child: SimpleDialog(
                          title: Text("ユーザ名変更"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                controller: _userNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '変更するユーザ名を入力してください',
                                ),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'ユーザ名が入力されていません';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                    child: Text("変更"),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        Firestore.instance
                                            .collection('users')
                                            .document(userData.userEmail)
                                            .updateData(<String, dynamic>{'name': _userNameController.text});
                                        userData.userName = _userNameController.text;
                                        _userNameController.text = "";
                                        setState(() {});
                                        Navigator.pop(context);
                                      }
                                    }),
                                FlatButton(
                                  child: Text("キャンセル"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          if (file != null)
            Container(
              height: 300,
              width: 300,
              child: Image.file(file),
            ),
          RaisedButton(
              child: const Text('アイコン追加'),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              onPressed: () async {
                showBottomSheet();
              }),
          Container(
            child: SignoutButton(),
          ),
        ],
      ),
    );
  }

  Widget showIcon() {
    if (userData.iconUrl != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(userData.iconUrl),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('images/account_circle.png'),
      );
    }
  }

  Future<int> showCupertinoBottomBar() {
    //選択するためのボトムシートを表示
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            message: Text('写真をアップロードしますか？'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  'カメラで撮影',
                ),
                onPressed: () {
                  Navigator.pop(context, 0);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(
                  'アルバムから選択',
                ),
                onPressed: () {
                  Navigator.pop(context, 1);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context, 2);
              },
              isDefaultAction: true,
            ),
          );
        });
  }

  void showBottomSheet() async {
    //ボトムシートから受け取った値によって操作を変える
    final result = await showCupertinoBottomBar();
    File imageFile;
    if (result == 0) {
      imageFile = await ImageUpload(ImageSource.camera).getImageFromDevice();
    } else if (result == 1) {
      imageFile = await ImageUpload(ImageSource.gallery).getImageFromDevice();
    }
    setState(() {
      file = imageFile;
    });
  }
}

class ImageUpload {
  ImageUpload(this.source, {this.quality = 50});

  final ImageSource source;
  final int quality;

  Future<File> getImageFromDevice() async {
    // 撮影/選択したFileが返ってくる
    final imageFile = await ImagePicker().getImage(source: source);
    // Androidで撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return null;
    }
    //画像を圧縮
    final File compressedFile = await FlutterNativeImage.compressImage(imageFile.path, quality: quality);

    return compressedFile;
  }
}
