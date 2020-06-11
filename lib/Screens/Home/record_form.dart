import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecordForm extends StatelessWidget {
  final TextEditingController _recordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _recordField,
          decoration: InputDecoration(
            labelText: '走った距離を入力してください',
            suffixIcon: IconButton(
              icon: Icon(Icons.directions_run),
            ),
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return '距離が入力されていません';
            }
            return null;
          },
        ),
      ],
    );
  }
}
