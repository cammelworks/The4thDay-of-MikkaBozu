import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:the4thdayofmikkabozu/SideMenu/sidemenu.dart';

class MyPage extends StatefulWidget {
  final String title = '記録ページ';
  MyPage();
  @override
  State<StatefulWidget> createState() => MyPageState();
}

class MyPageState extends State<MyPage>{
  DateTime _currentDate = DateTime.now();

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = date);
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
                        markedDateShowIcon: true,
                        markedDateIconMaxShown: 2,
                        todayTextStyle: TextStyle(
                          color: Colors.blue,
                        ),
                        markedDateIconBuilder: (event) {
                          return event.icon;
                        },
                        todayBorderColor: Colors.green,
                        markedDateMoreShowTotal: false
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
}