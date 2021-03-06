import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the4thdayofmikkabozu/SideMenu/signout_button.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class Sidemenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SidemenuState();
}

class SidemenuState extends State<Sidemenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
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
                            showBottomSheet();
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
    setState(() async {
      registerIcon(await upload(imageFile));
    });
  }

  //storageに保存
  Future<String> upload(File file) async {
    final StorageReference ref = FirebaseStorage.instance.ref();
    final StorageTaskSnapshot storedImage =
        await ref.child('icons').child(userData.userEmail.replaceAll('@', '')).putFile(File(file.path)).onComplete;
    final String downloadUrl = await loadImage(storedImage);
    return downloadUrl;
  }

  //url取得
  Future<String> loadImage(StorageTaskSnapshot storedImage) async {
    if (storedImage.error == null) {
      print('storageに保存しました');
      final String downloadUrl = await storedImage.ref.getDownloadURL() as String;
      return downloadUrl;
    } else {
      return null;
    }
  }

  void registerIcon(String downloadURL) {
    Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .updateData(<String, String>{'icon_url': downloadURL});
    setState(() {
      userData.iconUrl = downloadURL;
    });
  }
}

class ImageUpload {
  ImageUpload(this.source, {this.quality = 50});

  final ImageSource source;
  final int quality;

  Future<File> getImageFromDevice() async {
    // 撮影/選択したFileが返ってくる
    var imageFile = await ImagePicker().getImage(source: source);
    // Androidで撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return null;
    }
    //画像を圧縮
    final File compressedFile = await FlutterNativeImage.compressImage(imageFile.path, quality: quality);

    return _handleImageCrop(compressedFile);
  }

  Future<File> _handleImageCrop(File file) async {
    var croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '切り抜き',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.blue,
            initAspectRatio: CropAspectRatioPreset.original),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return croppedFile;
  }
}
