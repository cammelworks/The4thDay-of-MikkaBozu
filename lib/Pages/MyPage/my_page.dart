import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;
import 'package:the4thdayofmikkabozu/user_data.dart' as user_data;

class MyPage extends StatefulWidget {
  const MyPage();

  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  DateTime _currentDate = DateTime.now();
  final EventList<Event> _markedDateMap = EventList<Event>();
  bool _shouldShowRecord = false;
  String _selectedRecordDistance = '';
  String _selectedRecordTime = '';
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
    final QuerySnapshot recordsSnapshots = await Firestore.instance
        .collection('users')
        .document(user_data.userEmail)
        .collection('records')
        .orderBy('distance', descending: true)
        .getDocuments();

    double maxDistance = 0;

    for (int i = 0; i < recordsSnapshots.documents.length; i++) {
      // 走った距離の長さ順に並べ替えているのでそのまま値をとる
      if (i == 0) {
        maxDistance = recordsSnapshots.documents[i].data['distance'] as double;
      }
      final DateTime date = (recordsSnapshots.documents[i].data['timestamp'] as Timestamp).toDate();
      final double distance = recordsSnapshots.documents[i].data['distance'] as double;
      final double roundedDistance = (distance / 100).round() / 10;
      String time = '';
      int timeInt = 0;
      try {
        timeInt = recordsSnapshots.documents[i].data['time'] as int;
      } catch (e) {
        print(e);
      }
      time = _convertIntToTime(timeInt);
      addEvent(getDate(date), roundedDistance, time, getColorCode(maxDistance, distance));
    }
    setState(() {});
  }

  // 時間表示をStringに成形する
  String _convertIntToTime(int time) {
    // 129 -> 00:02:09
    int timeTmp = time;
    final int hour = (timeTmp / 3600).floor();
    timeTmp = timeTmp % 3600;
    final int minute = (timeTmp / 60).floor();
    timeTmp = timeTmp % 60;
    final int second = timeTmp;
    return hour.toString().padLeft(2, '0') +
        ':' +
        minute.toString().padLeft(2, '0') +
        ':' +
        second.toString().padLeft(2, '0');
  }

  void addEvent(DateTime date, double distance, String time, String colorCode) {
    _markedDateMap.add(date, createEvent(date, distance, time, colorCode));
  }

  // 時間以下を切り捨てる
  DateTime getDate(DateTime date) {
    final int year = date.year;
    final int month = date.month;
    final int day = date.day;
    return DateTime(year, month, day);
  }

  String getColorCode(double max, double distance) {
    final double distanceRatio = distance / max;
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

  final _tab = <Tab>[
    const Tab(text: '日'),
    const Tab(text: '週'),
    const Tab(text: '月'),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: _tab.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('記録ページ'),
          bottom: TabBar(
            tabs: _tab,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            const Text('unko'),
            const Text('unko'),
            Column(
              children: <Widget>[
                Expanded(
                  child: CalendarCarousel<Event>(
                    isScrollable: false,
                    onDayPressed: onDayPressed,
                    weekdayTextStyle: TextStyle(color: Colors.black87),
                    daysTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.black),
                    todayButtonColor: Colors.blue,
                    selectedDateTime: _currentDate,
                    selectedDayButtonColor: Colors.black26,
                    selectedDayBorderColor: Colors.transparent,
                    daysHaveCircularBorder: true,
                    customGridViewPhysics: const NeverScrollableScrollPhysics(),
                    markedDatesMap: _markedDateMap,
                    markedDateWidget: Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    ),
                    // showIconBehindDayText: true,
                    locale: 'ja',
                    todayBorderColor: Colors.transparent,
                  ),
                ),
                Visibility(
                  visible: _shouldShowRecord,
                  child: Card(
                      child: ListTile(
                          leading: Icon(
                            Icons.directions_run,
                            size: 40,
                          ),
                          title: Text(_selectedRecordDistance + '  ' + _selectedRecordTime),
                          subtitle: Text(_currentDate.month.toString() + '月' + _currentDate.day.toString() + '日'))),
                ),
              ],
            ),
          ],
        ),
        drawer: Sidemenu(),
      ),
    );
  }

  Event createEvent(DateTime date, double distance, String time, String colorCode) {
    if (colorCode == '9BD1E8') {
      return Event(
        date: date,
        title: distance.toString() + ',' + time,
        icon: Container(
          color: hex.HexColor(colorCode),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(date.day.toString()),
              Text(distance.toString() + 'km'),
            ],
          ),
        ),
      );
    } else {
      return Event(
        date: date,
        title: distance.toString() + ',' + time,
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
                distance.toString() + 'km',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void onDayPressed(DateTime date, List<Event> events) {
    setState(() => _currentDate = date);
    if (events.isNotEmpty) {
      _shouldShowRecord = true;
      final List<String> tmp = events[0].title.split(',');
      _selectedRecordDistance = tmp[0] + 'km';
      _selectedRecordTime = tmp[1];
    } else {
      _shouldShowRecord = false;
    }
  }

  // todo main.dartに移したい
  Future<void> _registerToken(String token) async {
    final QuerySnapshot snapshot =
        await Firestore.instance.collection('users').document(user_data.userEmail).collection('tokens').getDocuments();

    for (final document in snapshot.documents) {
      if (document.data['token'] == token) {
        return;
      }
    }

    // tokenをプッシュ
    Firestore.instance
        .collection('users')
        .document(user_data.userEmail)
        .collection('tokens')
        .document()
        .setData(<String, dynamic>{'token': token});
  }
}
