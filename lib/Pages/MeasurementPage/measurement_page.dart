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
  int _timeInt = 0;
  String _timeStr = "00:00:00";
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
                    MeasurementPanel(_distance, _timeStr),
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
                          await _pushMessage();
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
    _timeInt++;
    _convertIntToTime();
  }

  // 時間表示をStringに成形する
  void _convertIntToTime(){
    // 129 -> 00:02:09
    int timeTmp = _timeInt;
    int hour = (timeTmp / 3600).floor();
    timeTmp = timeTmp % 3600;
    int minute = (timeTmp / 60).floor();
    timeTmp = timeTmp % 60;
    int second = timeTmp;
    _timeStr = hour.toString().padLeft(2, "0") + ":"
        + minute.toString().padLeft(2, "0") + ":"
        + second.toString().padLeft(2, "0");
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

  // 走った距離と時間をデータベースにプッシュする
  Future<void> _pushRecord() async {
    DocumentSnapshot _record = await _confirmTodayRecord();
    if(_record == null){
      //同じ日のデータがない
      Firestore.instance
          .collection('users')
          .document(userData.userEmail)
          .collection('records')
          .document()
          .setData(<String, dynamic>{'distance': _distance, 'time': _timeInt, 'timestamp': Timestamp.now()});
    } else{
      // 同じ日のデータがある
      double _distanceTmp = (_distance * 10).round() / 10 + (_record.data["distance"] as double);
      int _time = _timeInt + (_record.data["time"] as int);
      Firestore.instance
          .collection('users')
          .document(userData.userEmail)
          .collection('records')
          .document()
          .setData(<String, dynamic>{'distance': _distanceTmp, 'time': _time, 'timestamp': Timestamp.now()});
    }
  }

  // 同じ日の記録があるか確認する
  Future<DocumentSnapshot> _confirmTodayRecord() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection('records')
        .orderBy("timestamp", descending: true)
        .getDocuments();
    if(snapshots.documents.length == 0){
      return null;
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
      return snapshots.documents[0];
    } else{
      return null;
    }
  }

  void _pushMessage() async {
    QuerySnapshot snapshot = await Firestore.instance.collection('users')
        .document(userData.userEmail).collection('teams').getDocuments();
    double roundedDistance = (_distance / 100).round() / 10;
    String message = userData.userName + 'さんが' + roundedDistance.toString() + 'Km走りました';
    for(int i = 0; i < snapshot.documents.length; i++){
      Firestore.instance.collection('teams').document(snapshot.documents[i].data['team_name'].toString())
          .collection('chats').document().setData(
          <String, dynamic>{'message': message, "sender": 'bot@gmail.com', "timestamp": Timestamp.now()});
    }
  }
}
