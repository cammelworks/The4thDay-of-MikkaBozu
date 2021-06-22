import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class MyPage extends StatefulWidget {
  final String title = '記録ページ';

  MyPage();

  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  DateTime _currentDate = DateTime.now();
  EventList<Event> _markedDateMap = EventList<Event>();
  bool _shouldShowRecord = false;
  String _selectedRecordDistance = "";
  String _selectedRecordTime = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    Future(() async {
      await addRecordedDate();
    });
    super.initState();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _registerToken(token);
      });
    });
  }

  Future<void> addRecordedDate() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection('records')
        .orderBy("distance", descending: true)
        .getDocuments();

    double max_distance;
    for (int i = 0; i < snapshots.documents.length; i++) {
      if (i == 0) {
        max_distance = snapshots.documents[i].data['distance'] as double;
      }
      DateTime date = (snapshots.documents[i].data['timestamp'] as Timestamp).toDate();
      double distance = snapshots.documents[i].data['distance'] as double;
      double roundedDistance = (distance / 100).round() / 10;
      String time = "";
      try {
        int timeInt = snapshots.documents[i].data['time'] as int;
        time = _convertIntToTime(timeInt);
      } catch (e) {
        time = " ";
      }
      addEvent(getDate(date), roundedDistance, time, getColorCode(max_distance, distance));
    }
    this.setState(() {});
  }

  // 時間表示をStringに成形する
  String _convertIntToTime(int time) {
    // 129 -> 00:02:09
    int timeTmp = time;
    int hour = (timeTmp / 3600).floor();
    timeTmp = timeTmp % 3600;
    int minute = (timeTmp / 60).floor();
    timeTmp = timeTmp % 60;
    int second = timeTmp;
    return hour.toString().padLeft(2, "0") +
        ":" +
        minute.toString().padLeft(2, "0") +
        ":" +
        second.toString().padLeft(2, "0");
  }

  // 時間情報を取り除く
  DateTime getDate(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;
    return (DateTime(year, month, day));
  }

  String getColorCode(double max, double distance) {
    double distanceRatio = distance / max;
    if (distanceRatio >= 0.75) {
      return '21576E';
    } else if (distanceRatio >= 0.5) {
      return '307FA1';
    } else if (distanceRatio >= 0.25) {
      return '419DC4';
    } else {
      return '9BD1E8';
    }
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
        title: Text(widget.title),
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
                    dayButtonColor: hex.HexColor('EBEDF0'),
                    weekFormat: false,
                    height: 420.0,
                    todayButtonColor: hex.HexColor('EBEDF0'),
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
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blue, width: 1.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(size.width / 10, 20, 10, 20),
                          child: Text(
                            _currentDate.month.toString() + '月' + _currentDate.day.toString() + '日',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
                          child: Text(
                            _selectedRecordDistance,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 6, size.width / 10, 6),
                          child: Text(
                            _selectedRecordTime,
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
      drawer: Sidemenu(),
    );
  }

  void addEvent(DateTime date, double distance, String time, String colorCode) {
    _markedDateMap.add(date, createEvent(date, distance, time, colorCode));
  }

  Event createEvent(DateTime date, double distance, String time, String colorCode) {
    if (colorCode == '9BD1E8') {
      return Event(
        date: date,
        title: distance.toString() + "," + time,
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
    } else {
      return Event(
        date: date,
        title: distance.toString() + "," + time,
        icon: Container(
          color: hex.HexColor(colorCode),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(color: Colors.white),
              ),
              Text(
                distance.toString() + "km",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = date);
    if (events.length > 0) {
      _shouldShowRecord = true;
      List<String> tmp = events[0].title.split(",");
      _selectedRecordDistance = tmp[0] + "km";
      _selectedRecordTime = tmp[1];
    } else {
      _shouldShowRecord = false;
    }
  }

  void _registerToken(String token) async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('users').document(userData.userEmail).collection('tokens').getDocuments();

    for (var document in snapshot.documents) {
      if (document.data['token'] == token) {
        return;
      }
    }

    // tokenをプッシュ
    Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection('tokens')
        .document()
        .setData(<String, dynamic>{'token': token});
  }
}
