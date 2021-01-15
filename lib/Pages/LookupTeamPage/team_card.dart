import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/LookupTeamPage/join_button.dart';

class TeamCard extends StatelessWidget {
  DocumentSnapshot _snapshot;
  TeamCard(this._snapshot) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(8.0),
        child: Container(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _snapshot.data["team_name"].toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    TeamOverview(_snapshot.data["team_overview"].toString()),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        teamGoal(_snapshot.data["goal"].toString()),
                        teamMemberNum(_snapshot.data["user_num"].toString())
                      ],
                    ),
                    Spacer(),
                    JoinButton(_snapshot.data["team_name"].toString()),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget TeamOverview(String teamOverview) {
    if (teamOverview == "null") {
      return Container();
    }
    return Text(
      "概要：" + teamOverview,
      style: TextStyle(color: Colors.black54),
    );
  }

  Widget teamGoal(String goal) {
    if (goal == "null") {
      return Container();
    }
    return Row(
      children: <Widget>[
        Image.asset(
          'images/flag-icon.png',
          height: 16.0,
          width: 16.0,
        ),
        Text(goal + "km"),
      ],
    );
  }

  Widget teamMemberNum(String userNum) {
    if (userNum == "null") {
      return Container();
    }
    return Row(
      children: <Widget>[
        Icon(Icons.people_outline),
        Text(userNum + "人"),
      ],
    );
  }
}
