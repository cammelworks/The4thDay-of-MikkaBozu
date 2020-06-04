import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../teamcreate_page.dart';

class TeamCreateButton extends StatelessWidget {
  String _email;
  //コンストラクタ
  TeamCreateButton(this._email);

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
                  child: const Text('チーム作成'),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onPressed: () async {
                    //チーム作成ページに移動
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamCreatePage(_email),
                        ));
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
