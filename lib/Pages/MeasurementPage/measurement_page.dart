import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MeasurementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeasurementPageState();
}

class MeasurementPageState extends State<MeasurementPage> {
  List<String> buttonStateList = ['START', 'STOP', 'My Page'];
  int _value = 0;
  Position position; // Geolocator
  bool _showLocation = false;
  @override
  void initState() {
    super.initState();
    _getLocation();
    Timer.periodic(
      Duration(seconds: 1),
      countTime,
    );
  }

  Future<void> _getLocation() async {
    Position _currentPosition = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // ここで精度を「high」に指定している
    print(_currentPosition);
    setState(() {
      position = _currentPosition;
    });
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
                    Center(
                      child: ButtonTheme(
                        minWidth: 100,
                        height: 100,
                        child: RaisedButton(
                          child: Text(buttonStateList[_value]),
                          color: Colors.white,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            if (_value < 2) {
                              setState(() {
                                _value++;
                                _showLocation = true;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: showLocation(),
                    ),
                  ]),
            ),
          );
        });
  }

  void countTime(Timer timer) async {
    await _getLocation();
    showLocation();
  }

  Widget showLocation() {
    if (_showLocation) {
      //登録ボタンの表示
      return Column(
        children: <Widget>[
          Text("${position}"),
          FutureBuilder(
            future: getDistance(),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              } else {
                return Center(child: Text("距離計算中"));
              }
            },
          ),
//          Text(await Geolocator().distanceBetween(position.latitude, position.longitude, 34.4015, 132.714))
        ],
      );
    } else {
      //何も表示しない
      return null;
    }
  }

  Future<Widget> getDistance() async {
    double distance = await Geolocator()
        .distanceBetween(
        position.latitude, position.longitude, 34.4015, 132.714);
    print(distance);
    return Text("${distance}");
  }
}
