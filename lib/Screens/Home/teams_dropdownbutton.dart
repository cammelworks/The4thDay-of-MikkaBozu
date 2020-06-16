import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/Screens/Home/to_teampage_button.dart';

class TeamsDropdownButton extends StatefulWidget {
  String _email;
  TeamsDropdownButton(this._email);
  @override
  TeamsDropdownButtonState createState() => TeamsDropdownButtonState(_email);
}

class TeamsDropdownButtonState extends State<TeamsDropdownButton> {
  String _email;
  String _selectedTeamName; //選択されているドロップダウンアイテム
  TeamsDropdownButtonState(this._email);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: StreamBuilder<QuerySnapshot>(
              //表示したいFirestoreの保存先を指定
              stream: Firestore.instance
                  .collection('users')
                  .document(_email)
                  .collection('teams')
                  .snapshots(),
              //streamが更新されるたびに呼ばれる
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                //データが取れていない時の処理
                if (!snapshot.hasData) return const Text('Loading...');

                //ドロップダウンボタン
                return Container(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      hint: Text("チーム名を選択してください"),
                      value: _selectedTeamName,
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedTeamName = newValue;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                          value: document.data["team_name"],
                          child: Text(
                            document.data["team_name"],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
                ;
              }),
        ),
        Center(
          child: ToTeampageButton(_selectedTeamName),
        ),
      ],
    );
  }
}
