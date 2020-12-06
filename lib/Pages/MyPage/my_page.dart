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
    if(events.length > 0){
      Fluttertoast.showToast(msg: events[0].title + "km");
    }
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
        .orderBy("distance", descending: true)
        .getDocuments();

    double max_distance;
    for(int i=0; i<snapshots.documents.length; i++){
      if(i == 0){
        max_distance = snapshots.documents[i].data['distance'] as double;
      }
      DateTime date = (snapshots.documents[i].data['timestamp'] as Timestamp).toDate();
      double distance = snapshots.documents[i].data['distance'] as double;
      double roundedDistance = (distance / 100).round() / 10;
      addEvent(getDate(date), roundedDistance, getColorCode(max_distance, distance));
    }
    this.setState(() {});
  }

  // 時間情報を取り除く
  DateTime getDate(DateTime date){
    int year = date.year;
    int month = date.month;
    int day = date.day;
    return(DateTime(year, month, day));
  }

  String getColorCode(double max, double distance){
    int tmp = ((1 - distance / max) * 100).round();
    return '00' + tmp.toString().padLeft(2, '0') + 'c4';
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
                        todayButtonColor: Colors.white,
                        selectedDateTime: _currentDate,
                        daysHaveCircularBorder: false,
                        customGridViewPhysics: NeverScrollableScrollPhysics(),
                        markedDatesMap: _markedDateMap,
                        markedDateShowIcon: true,
                        markedDateIconMaxShown: 2,
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
            ],
          ),
        ),
      ),
      drawer: Sidemenu(),
    );
  }

  void addEvent(DateTime date, double distance, String colorCode) {
    print(colorCode);
    _markedDateMap.add(date, createEvent(date, distance, colorCode));
  }  // 追加

  Event createEvent(DateTime date, double distance, String colorCode) {
    return Event(
        date: date,
        title: distance.toString(),
        icon: Container(
          color: HexColor(colorCode),
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

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}