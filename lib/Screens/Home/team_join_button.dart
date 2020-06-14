import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../teamcreate_page.dart';

class TeamJoinButton extends StatelessWidget {
  String _selectedTeamName;
  //コンストラクタ
  TeamJoinButton(this._selectedTeamName);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
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
                    print(_selectedTeamName);
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
