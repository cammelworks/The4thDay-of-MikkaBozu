import 'package:flutter/material.dart';

class MeasurementPanel extends StatelessWidget {
  double _distance = 0;
  String _time = "";
  MeasurementPanel(this._distance, this._time);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(size.width / 20, size.height / 10, size.width / 20, size.height / 10),
      child: Column(
        children: <Widget>[
          //時間表示のボックス
          Center(
            child: Text(
              _time,
              style:
                  TextStyle(fontSize: 100, fontFamily: 'BebasNeue', color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          //距離表示のボックス
          Center(
            child: Text(
              _convertUnit(),
              style:
                  TextStyle(fontSize: 100, fontFamily: 'BebasNeue', color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
        ],
      ),
    );
  }

  String _convertUnit() {
    // _distanceはメートル
    // 距離をkmで表示する
    //表示するときに丸め誤差が生じるため、小数点2位以下を切り捨てる
    double km_distance = _distance / 1000.0;
    return "${(km_distance * 10).round() / 10}" + "km";
  }
}
