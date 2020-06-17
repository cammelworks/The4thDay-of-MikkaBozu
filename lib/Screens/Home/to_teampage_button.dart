import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../teamcreate_page.dart';
import '../../team_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToTeampageButton extends StatelessWidget {
  String _selectedTeamName;
  //コンストラクタ
  ToTeampageButton(this._selectedTeamName);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: ButtonTheme(
          minWidth: 200.0,
          height: 50.0,
          buttonColor: Colors.white,
          child: RaisedButton(
              child: const Text('チームページへ'),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              onPressed: () async {
                if(this._selectedTeamName != null){
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamPage(this._selectedTeamName),
                      ));
                } else {
                  Fluttertoast.showToast(
                    msg: 'チームを選択してください',
                  );
                }
              }),
        ),
      ),
    );
  }
}
