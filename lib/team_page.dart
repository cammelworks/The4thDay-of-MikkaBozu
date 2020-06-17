import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

class TeamPage extends StatefulWidget {
  String _TeamName;
  //コンストラクタ
  TeamPage(this._TeamName);
  @override
  State<StatefulWidget> createState() => TeamPageState(_TeamName);
}

class TeamPageState extends State<TeamPage> {
  String _TeamName;
  //コンストラクタ
  TeamPageState(this._TeamName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_TeamName),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    '目標',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Center(
                child: RaisedButton(
                  child: Text('チーム目標'),
                  onPressed: () {
                    showPickerNumber(context);
                  },
                ),
              ),
            ]),
      ),
    );
  }

  showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 10, jump: 1),
        ]),
        delimiter: [
//          PickerDelimiter(
//              child: Container(
//            width: 30.0,
//            alignment: Alignment.center,
//          ))
        ],
        hideHeader: true,
        title: Text("チーム目標を設定してください"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        confirmText: "決定",
        cancelText: "キャンセル",
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }).showDialog(context);
  }
}
