import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_button.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_panel.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:the4thdayofmikkabozu/permission.dart';

class MeasurementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeasurementPageState();
}

class MeasurementPageState extends State<MeasurementPage> {
  int _value = 0;
  Position position; // Geolocator
  Position prevPosition;
  Timer _timer;
  double _distance = 0;
  static const platform = const MethodChannel("Java.Foreground");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeolocationStatus>(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == GeolocationStatus.denied) {
//            return Scaffold(
//              body: Text(
//                'Access to location denied',
//                textAlign: TextAlign.center,
//              ),
//            );
            Permission().checkPermission();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('時間・距離計測ページ'),
            ),
            body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MeasurementPanel(_distance),
                    Center(
                      child: MeasurementButton(_value, () async {
                        if (_value == 0) {
                          if (Platform.isAndroid) {
                            platform.invokeMethod<dynamic>("ON");
                          }
                          //countTime()を1秒ごとに実行
                          _timer = Timer.periodic(
                            Duration(seconds: 1),
                            countTime,
                          );
                        } else if (_value == 1) {
                          if (Platform.isAndroid) {
                            platform.invokeMethod<dynamic>("OFF");
                          }
                          _timer.cancel();
                          await _pushRecord();
                        } else {
                          Navigator.pop(context);
                        }
                        setState(() {
                          _value++;
                        });
                      }),
                    ),
                  ]),
            ),
          );
        });
  }

  void countTime(Timer timer) {
    _getLocation();
  }

  Future<void> _getLocation() async {
    Position _currentPosition = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    if (position == null) {
      prevPosition = _currentPosition;
    } else {
      prevPosition = position;
    }
    position = _currentPosition;
    // 距離の計算
    double distance = await Geolocator().distanceBetween(prevPosition.latitude,
        prevPosition.longitude, position.latitude, position.longitude);
    //小数点2位以下を切り捨てて距離に加算する
    _distance += (distance * 10).round() / 10;
    // 画面の更新
    setState(() {});
  }

  // 走った距離をデータベースにプッシュする
  Future<void> _pushRecord() async {
    dynamic _recordDistance = await _confirmTodayRecord();
    print((_recordDistance as double));
    _distance = (_distance * 10).round() / 10 + (_recordDistance as double);
    Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection('records')
        .document()
        .setData(<String, dynamic>{'distance': _distance, 'timestamp': Timestamp.now()});
  }

  // 同じ日の記録があるか確認する
  Future<dynamic> _confirmTodayRecord() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection('records')
        .orderBy("timestamp", descending: true)
        .getDocuments();
    if(snapshots.documents.length == 0){
      return 0.0;
    }
    // 直近の記録の日付を確認する
    DateTime time = (snapshots.documents[0].data['timestamp'] as Timestamp).toDate();
    int year = time.year;
    int month = time.month;
    int day = time.day;
    DateTime today = Timestamp.now().toDate();
    // 直近の記録と同じ日付ならその日の記録を返す
    if(year == today.year && month == today.month && day == today.day){
      Firestore.instance
          .collection('users')
          .document(userData.userEmail)
          .collection('records')
          .document(snapshots.documents[0].documentID)
          .delete();
      return snapshots.documents[0].data['distance'];
    } else{
      return 0.0;
    }
  }
}
