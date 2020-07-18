import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_button.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_panel.dart';
import 'dart:async';
import 'dart:io';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:flutter/services.dart';

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
  static const platform = const MethodChannel("Java.Foreground");

  Future<void> _getLocation() async {
    Position _currentPosition = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    if (position == null) {
      prevPosition = _currentPosition;
    }
    else {
      prevPosition = position;
    }
    position = _currentPosition;
    // 距離の計算
    double distance = await Geolocator().distanceBetween(prevPosition.latitude,
        prevPosition.longitude, position.latitude, position.longitude);
    //小数点2位以下を切り捨てて距離に加算する
    _distance += (distance * 10).round() / 10;
    setState(() {
    });
    print(_currentPosition);
    print(_distance);
  }

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
                    MeasurementPanel(_distance),
                    Center(
                      child: MeasurementButton(_value, () {
                        if(_value == 0){
                          if (Platform.isAndroid){
                            platform.invokeMethod("ON");
                          }
                          _timer = Timer.periodic(
                            Duration(seconds: 1),
                            countTime,
                          );
                        } else if(_value ==1){
                          if (Platform.isAndroid){
                            platform.invokeMethod("OFF");
                          }
                          _timer.cancel();
                          _pushRecord();
                        }
                        else {
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

//  Future<Widget> getDistance() async {
//    double distance = await Geolocator().distanceBetween(prevPosition.latitude,
//        prevPosition.longitude, position.latitude, position.longitude);
//    //小数点2位以下を切り捨てて距離に加算する
//    _distance += (distance * 10).round() / 10;
//    return MeasurementPanel(_distance);
//  }

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
        //丸め誤差が生じるため、小数点2位以下を切り捨てる
        _distance = (_distance * 10).round() / 10;
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
