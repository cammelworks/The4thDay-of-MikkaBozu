import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:fluttertoast/fluttertoast.dart';

class MyPage extends StatefulWidget {
  final String title = '記録ページ';
  MyPage();
  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage>{
  DateTime _currentDate = DateTime.now();
  EventList<Event> _markedDateMap = EventList<Event>();

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = date);
    Fluttertoast.showToast(msg: events[0].title + "km");
  }

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
        .document(userData.userEmail)
        .collection('records')
        .orderBy("timestamp", descending: true)
        .getDocuments();

    for(int i=0; i<snapshots.documents.length; i++){
      // 時間情報を取り除く
      DateTime time = (snapshots.documents[i].data['timestamp'] as Timestamp).toDate();
      int year = time.year;
      int month = time.month;
      int day = time.day;
      double distance = (snapshots.documents[i].data['distance'] as double) / 1000.0;
      addEvent(DateTime(year, month, day), (distance * 10).round() / 10);
    }
    this.setState(() {});
  }

  @override
  void dispose(){
    _markedDateMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:SingleChildScrollView(
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
                        weekFormat: false,
                        height: 420.0,
                        selectedDateTime: _currentDate,
                        daysHaveCircularBorder: false,
                        customGridViewPhysics: NeverScrollableScrollPhysics(),
                        markedDatesMap: _markedDateMap,
                        markedDateShowIcon: true,
                        markedDateIconMaxShown: 2,
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
            ],
          ),
        ),
      ),
      drawer: Sidemenu(),
    );
  }

  void addEvent(DateTime date, double distance) {
    _markedDateMap.add(date, createEvent(date, distance));
  }  // 追加

  Event createEvent(DateTime date, double distance) {
    return Event(
        date: date,
        title: distance.toString(),
        icon: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 1.0)),
            child: Icon(
              Icons.calendar_today,
              color: Colors.blue,
            )
        )
    );
  } // 追加
}