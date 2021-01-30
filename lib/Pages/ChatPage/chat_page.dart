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
  //コンストラクタ
  ChatPageState(this._teamName);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _chatField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                //表示したいFirestoreの保存先を指定
                  stream: Firestore.instance.collection('teams')
                      .document(_teamName)
                      .collection('chats')
                      .orderBy("timestamp", descending: false)
                      .snapshots(),
                  //streamが更新されるたびに呼ばれる
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    //データが取れていない時の処理
                    if (!snapshot.hasData) return const Text('Loading...');
                    return Scrollbar(
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) =>
                              _buildListItem(context, snapshot.data.documents[index])),
                    );
                  }),
            ),
          ),
          Container(
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
                color: Colors.white
              ),
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
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot documentSnapshot) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 50,
            ),
            Padding(padding: EdgeInsets.only(left: 10),),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // メールアドレスからユーザー名を取得する
                    StreamBuilder<DocumentSnapshot>(
                      //表示したいFirestoreの保存先を指定
                        stream: Firestore.instance.collection('users')
                            .document(documentSnapshot.data["sender"].toString())
                            .snapshots(),
                        //streamが更新されるたびに呼ばれる
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          //データが取れていない時の処理
                          if (!snapshot.hasData) return const Text('Loading...');
                          String name;
                          if(snapshot.data['name'] != null){
                            name = snapshot.data['name'].toString();
                          } else {
                            name = "Guest";
                          }
                          return Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )
                          );
                        }),
                    Padding(padding: EdgeInsets.only(left: 12),),
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
            ),
          ]
      ),
    );
  }

  void pushMessage() {
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('chats')
        .document()
        .setData(<String, dynamic>{
          'message': _chatField.text,
          "sender": userData.userEmail,
          "timestamp":Timestamp.now()
        });
    _chatField.text = "";
  }

  String convertDate(Timestamp timestamp){
    DateTime dateTime = timestamp.toDate();
    String month = dateTime.month.toString();
    String day = dateTime.day.toString();
    String hour = dateTime.hour.toString();
    String minute = dateTime.minute.toString();

    return month + "/" + day + " " + hour + ":" + minute;
  }
}
