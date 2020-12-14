import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;

class MemberPage extends StatefulWidget {
  String _email;
  //コンストラクタ
  MemberPage(this._email);
  @override
  State<StatefulWidget> createState() => MemberPageState(_email);
}

class MemberPageState extends State<MemberPage> {
  String _email;
  DateTime _currentDate = DateTime.now();
  EventList<Event> _markedDateMap = EventList<Event>();
  bool _shouldShowRecord = false;
  String _selectedRecord = "";

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = date);
    if (events.length > 0) {
      _shouldShowRecord = true;
      _selectedRecord = events[0].title + "km";
    } else {
      _shouldShowRecord = false;
    }
  }

  //コンストラクタ
  MemberPageState(this._email);

  @override
  void initState() {
    Future(() async {
      await addRecordedDate();
    });
    super.initState();
  }

  Future<void> addRecordedDate() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('users')
        .document(_email)
        .collection('records')
        .orderBy("distance", descending: true)
        .getDocuments();

    double max_distance;
    for (int i = 0; i < snapshots.documents.length; i++) {
      if (i == 0) {
        max_distance = snapshots.documents[i].data['distance'] as double;
      }
      DateTime date =
      (snapshots.documents[i].data['timestamp'] as Timestamp).toDate();
      double distance = snapshots.documents[i].data['distance'] as double;
      double roundedDistance = (distance / 100).round() / 10;
      addEvent(
          getDate(date), roundedDistance, getColorCode(max_distance, distance));
    }
    this.setState(() {});
  }

  // 時間情報を取り除く
  DateTime getDate(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;
    return (DateTime(year, month, day));
  }

  String getColorCode(double max, double distance) {
    int tmp = ((1 - distance / max) * 100).round();
    return '00' + tmp.toString().padLeft(2, '0') + 'c4';
  }

  @override
  void dispose() {
    _markedDateMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(_email),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Center(
                  child: CalendarCarousel<Event>(
                    onDayPressed: onDayPressed,
                    weekendTextStyle: TextStyle(color: Colors.red),
                    thisMonthDayBorderColor: Colors.grey,
                    weekFormat: true,
                    height: 200.0,
                    todayButtonColor: Colors.white,
                    selectedDateTime: _currentDate,
                    daysHaveCircularBorder: false,
                    customGridViewPhysics: NeverScrollableScrollPhysics(),
                    markedDatesMap: _markedDateMap,
                    markedDateShowIcon: true,
                    markedDateIconMaxShown: 2,
                    markedDateIconMargin: 0,
                    locale: "ja",
                    todayTextStyle: TextStyle(
                      color: Colors.blue,
                    ),
                    markedDateIconBuilder: (event) {
                      return event.icon;
                    },
                    todayBorderColor: Colors.green,
                    markedDateMoreShowTotal: false,
                  ),
                ),
              ),
              Visibility(
                visible: _shouldShowRecord,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue, width: 1.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding:
                          EdgeInsets.fromLTRB(size.width / 10, 20, 10, 20),
                          child: Text(
                            _currentDate.month.toString() +
                                '月' +
                                _currentDate.day.toString() +
                                '日',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      Container(
                          padding:
                          EdgeInsets.fromLTRB(10, 6, size.width / 10, 6),
                          child: Text(
                            _selectedRecord,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addEvent(DateTime date, double distance, String colorCode) {
    _markedDateMap.add(date, createEvent(date, distance, colorCode));
  } // 追加

  Event createEvent(DateTime date, double distance, String colorCode) {
    return Event(
      date: date,
      title: distance.toString(),
      icon: Container(
        color: hex.HexColor(colorCode),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(date.day.toString()),
            Text(distance.toString() + "km"),
          ],
        ),
      ),
    );
  } // 追加
}
