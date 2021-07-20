import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_button.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the4thdayofmikkabozu/permission.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

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
  GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  static const platform = const MethodChannel("Java.Foreground");

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder<GeolocationStatus>(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder: (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == GeolocationStatus.denied) {
            Permission().checkPermission();
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
            ),
            body: FutureBuilder<Position>(
              future: _getLocation(),
              builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                _updateCamera();
                return Container(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      MeasurementPanel(_distance, _timeStr),
                      // mapの表示
                      Container(
                        height: size.height / 3,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, size.height / 20),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                            zoom: 15,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          markers: _createMarker(),
                          polylines: Set<Polyline>.of(polylines.values),
                          zoomGesturesEnabled: true,
                        ),
                      ),
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
              }
            ),
          );
        });
  }

  void countTime(Timer timer) {
    // 画面の更新
    if (this.mounted) {
      setState(() {});
    }
    _timeInt++;
    _convertIntToTime();
  }

  // 時間表示をStringに成形する
  void _convertIntToTime() {
    // 129 -> 00:02:09
    int timeTmp = _timeInt;
    int hour = (timeTmp / 3600).floor();
    timeTmp = timeTmp % 3600;
    int minute = (timeTmp / 60).floor();
    timeTmp = timeTmp % 60;
    int second = timeTmp;
    _timeStr = hour.toString().padLeft(2, "0") +
        ":" +
        minute.toString().padLeft(2, "0") +
        ":" +
        second.toString().padLeft(2, "0");
  }

  Future<Position> _getLocation() async {
    Position _currentPosition =
        await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    if (position == null) {
      prevPosition = _currentPosition;
    } else {
      prevPosition = position;
    }
    position = _currentPosition;
    // 距離の計算
    double distance = await Geolocator()
        .distanceBetween(prevPosition.latitude, prevPosition.longitude, position.latitude, position.longitude);
    //小数点2位以下を切り捨てて距離に加算する
    _distance += (distance * 10).round() / 10;
    // 緯度経度の配列に現在地を追加
    polylineCoordinates.add(LatLng(position.latitude, position.longitude));
    PolylineId id = PolylineId('poly');
    // polylineを更新
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: Colors.red,
      width: 3,
    );
    polylines[id] = polyline;
    return position;
  }

  // 走った距離と時間をデータベースにプッシュする
  Future<void> _pushRecord() async {
    DocumentSnapshot _record = await _confirmTodayRecord();
    if (_record == null) {
      //同じ日のデータがない
      Firestore.instance
          .collection('users')
          .document(userData.userEmail)
          .collection('records')
          .document()
          .setData(<String, dynamic>{'distance': _distance, 'time': _timeInt, 'timestamp': Timestamp.now()});
    } else {
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
    if (snapshots.documents.length == 0) {
      return null;
    }
    // 直近の記録の日付を確認する
    DateTime time = (snapshots.documents[0].data['timestamp'] as Timestamp).toDate();
    int year = time.year;
    int month = time.month;
    int day = time.day;
    DateTime today = Timestamp.now().toDate();
    // 直近の記録と同じ日付ならその日の記録を返す
    if (year == today.year && month == today.month && day == today.day) {
      Firestore.instance
          .collection('users')
          .document(userData.userEmail)
          .collection('records')
          .document(snapshots.documents[0].documentID)
          .delete();
      return snapshots.documents[0];
    } else {
      return null;
    }
  }

  void _pushMessage() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('users').document(userData.userEmail).collection('teams').getDocuments();
    double roundedDistance = (_distance / 100).round() / 10;
    String message = userData.userName + 'さんが' + roundedDistance.toString() + 'Km走りました';
    for (int i = 0; i < snapshot.documents.length; i++) {
      Firestore.instance
          .collection('teams')
          .document(snapshot.documents[i].data['team_name'].toString())
          .collection('chats')
          .document()
          .setData(<String, dynamic>{'message': message, "sender": 'bot@gmail.com', "timestamp": Timestamp.now()});
    }
  }

  Set<Marker> _createMarker() {
    return {
      Marker(
        markerId: MarkerId("marker_1"),
        position: LatLng(position.latitude, position.longitude),
      ),
    };
  }

  void _updateCamera() {
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
            LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }
}
