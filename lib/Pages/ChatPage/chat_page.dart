import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class ChatPage extends StatefulWidget {
  final String title = 'チーム内チャット';
  String _teamName;
  //コンストラクタ
  ChatPage(this._teamName);

  @override
  State<StatefulWidget> createState() => ChatPageState(_teamName);
}

class ChatPageState extends State<ChatPage> {
  String _teamName;
  String _email = userData.userEmail;
  //コンストラクタ
  ChatPageState(this._teamName);
  ScrollController _scrollController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _chatField = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {});
    updateLastVisited();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: StreamBuilder<QuerySnapshot>(
                    //表示したいFirestoreの保存先を指定
                    stream: Firestore.instance
                        .collection('teams')
                        .document(_teamName)
                        .collection('chats')
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    //streamが更新されるたびに呼ばれる
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      //データが取れていない時の処理
                      if (!snapshot.hasData) return const Text('Loading...');
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          reverse: true,
                          controller: _scrollController,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]));
                    }),
              ),
            ),
            SafeArea(
              child: Container(
                color: Colors.primaries[5],
                child: Container(
                  margin: EdgeInsets.fromLTRB(3, 3, 3, 3),
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.primaries[5],
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _chatField,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  pushMessage();
                                  // 再レンダリング
                                  setState(() {});
                                }
                                //キーボードを閉じる
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void updateLastVisited() {
    Firestore.instance
        .collection('users')
        .document(_email)
        .collection('teams')
        .document(_teamName)
        .updateData(<String, dynamic>{
      "last_visited": Timestamp.now(),
    });

    userData.hasNewChat[_teamName] = false;
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot documentSnapshot) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: StreamBuilder<DocumentSnapshot>(
          stream:
              Firestore.instance.collection('users').document(documentSnapshot.data["sender"].toString()).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData)
              return Container(
                height: size.height,
                width: size.width,
                child: Center(child: CircularProgressIndicator()),
              );
            String name;
            Widget icon;
            if (snapshot.data['name'] != null) {
              name = snapshot.data['name'].toString();
            } else {
              name = "Guest";
            }
            if (snapshot.data['icon_url'].toString() != 'null') {
              icon = CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(snapshot.data['icon_url'].toString()),
              );
            } else {
              icon = CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/account_circle.png'),
              );
            }
            return Row(
              children: <Widget>[
                icon,
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                        ),
                        Text(
                          convertDate(documentSnapshot.data["timestamp"] as Timestamp),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Text(documentSnapshot.data["message"].toString()),
                  ],
                )
              ],
            );
          }),
    );
  }

  void pushMessage() {
    Firestore.instance.collection('teams').document(_teamName).collection('chats').document().setData(
        <String, dynamic>{'message': _chatField.text, "sender": userData.userEmail, "senderName": userData.userName, "timestamp": Timestamp.now()});
    _chatField.text = "";
    updateLastVisited();
  }

  String convertDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String month = dateTime.month.toString();
    String day = dateTime.day.toString();
    String hour = dateTime.hour.toString();
    String minute = dateTime.minute.toString();

    return month + "/" + day + " " + hour + ":" + minute;
  }
}
