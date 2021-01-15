import 'package:cloud_firestore/cloud_firestore.dart';
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
                  stream: Firestore.instance.collection('teams').document(_teamName).collection('chats').snapshots(),
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
          Form(
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
        ],
      )
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot documentSnapshot) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Text(
        documentSnapshot.data["message"].toString()
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
          "sender": userData.userName,
          "timestamp":Timestamp.now()
        });
    _chatField.text = "";
  }
}
