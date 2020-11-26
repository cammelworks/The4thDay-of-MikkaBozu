import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MemberPage/member_page.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class MembersRecord extends StatelessWidget {
  String _teamName;

  MembersRecord(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'メンバー',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        getMembers(),
      ],
    );
  }

  //メンバー一覧を表示する
  Widget getMembers() {
    return StreamBuilder<QuerySnapshot>(
        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('teams')
            .document(_teamName)
            .collection('users')
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');

          return Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, int index) {
                if (snapshot.data.documents[index].documentID.toString() ==
                    userData.userEmail) {
                  return Container();
                }
                return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
                  title: Text(
                      snapshot.data.documents[index].documentID.toString()),
                  onTap: () => Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (context) => MemberPage(snapshot
                            .data.documents[index].documentID
                            .toString()),
                      )),
                );
              },
            ),
          );
        });
  }
}
