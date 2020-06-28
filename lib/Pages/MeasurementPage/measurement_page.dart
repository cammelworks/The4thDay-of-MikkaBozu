import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class MeasurementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeasurementPageState();
}

class MeasurementPageState extends State<MeasurementPage> {
  List<String> buttonStateList = ['START', 'STOP', 'My Page'];
  int _value = 0;
  Position position; // Geolocator
  Position prevPosition;
  Timer _timer;
  double _distance = 0;

  Future<void> _getLocation() async {
    Position _currentPosition = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    print(_currentPosition);
    setState(() {
      prevPosition = position;
      position = _currentPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder<GeolocationStatus>(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == GeolocationStatus.denied) {
            return Text(
              'Access to location denied',
              textAlign: TextAlign.center,
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('時間・距離計測ページ'),
            ),
            body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //四角い枠のpadding
                    Padding(
                      padding: EdgeInsets.fromLTRB(size.width / 20,
                          size.height / 10, size.width / 20, size.height / 10),
                      child: Column(
                        children: <Widget>[
                          //時間表示のボックス
                          Container(
                            height: size.height / 6,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.timer,
                                  size: size.height / 12,
                                ),
                                Container(
                                  width: size.width * 2 / 3,
                                  child: Center(
                                    child: Text(
                                      "00:00:00",
                                      style: TextStyle(
                                        fontSize: size.width / 7,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //距離表示のボックス
                          Container(
                            height: size.height / 6,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.directions_run,
                                  size: size.height / 12,
                                ),
                                Container(
                                  width: size.width * 2 / 3,
                                  child: FutureBuilder(
                                    future: getDistance(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.hasData) {
                                        return Center(
                                          child: Text(
                                            snapshot.data,
                                            style: TextStyle(
                                              fontSize: size.width / 6,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Center(
                                          child: Text(
                                            "0.0m",
                                            style: TextStyle(
                                              fontSize: size.width / 6,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: ButtonTheme(
                        minWidth: size.width / 2,
                        height: size.height / 4,
                        child: RaisedButton(
                          child: Text(buttonStateList[_value]),
                          color: Colors.white,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: Colors.black,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            //スタート
                            if (_value == 0) {
                              _timer = Timer.periodic(
                                Duration(seconds: 1),
                                countTime,
                              );
                              setState(() {
                                _value++;
                              });
                            }
                            //ストップ
                            else if (_value == 1) {
                              _timer.cancel();
                              //集計距離をFireStoreにプッシュ
                              _pushRecord();
                              setState(() {
                                _value++;
                              });
                            }
                            //マイページに戻る
                            else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  void countTime(Timer timer) async {
    await _getLocation();
    //showLocation();
  }

  //2点間の距離の計算
  Future<String> getDistance() async {
    double distance = await Geolocator().distanceBetween(prevPosition.latitude,
        prevPosition.longitude, position.latitude, position.longitude);
    //小数点2位以下を切り捨てて距離に加算する
    _distance += (distance * 10).round() / 10;
    // _distanceはメートル
    // 距離が1000.0m以上のときkmに変換する
    //表示するときに丸め誤差が生じるため、小数点2位以下を切り捨てる
    if (_distance >= 1000.0) {
      double km_distance = _distance / 1000.0;
      return "${(km_distance * 10).round() / 10}" + "km";
    }
    // 1000.0mより小さいときはmで表示
    else {
      return "${(_distance * 10).round() / 10}" + "m";
    }
  }

  void _pushRecord() async {
    //自分のEmailに紐づくドキュメントを取得
    getData() async {
      return await Firestore.instance
          .collection('users')
          .where("email", isEqualTo: userData.userEmail)
          .getDocuments();
    }

    getData().then((val) {
      //データの更新
      //FireStoreにはメートルとしてデータを格納
      if (val.documents.length > 0) {
        String userDocId = val.documents[0].documentID;
        Firestore.instance
            .collection('users')
            .document(userDocId)
            .collection('records')
            .document()
            .setData({'distance': _distance, 'timestamp': Timestamp.now()});
      } else {
        print("Not Found");
      }
    });
  }
}
