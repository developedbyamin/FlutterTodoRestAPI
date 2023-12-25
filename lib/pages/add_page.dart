import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? item;

  const AddPage({super.key, this.item});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final item = widget.item;
    if(widget.item != null){
      isEdit = true;
      final title = item?['title'];
      final description = item?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit? 'Düzəliş et' : 'Tapşırıq əlavə et'
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5C8374))
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5C8374))
              ),
              hintText: 'Başlıq',
            ),
            cursorColor: Color(0xFF5C8374),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF5C8374))
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5C8374))
              ),
              hintText: 'Məzmun',
            ),
            cursorColor: Color(0xFF5C8374),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: isEdit? updateData : sendData,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                isEdit? 'Təsdiqlə' : 'Göndər',
              ),
            ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Color(0xFF5C8374)),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async{
    final item = widget.item;
    if(item == null){
      print('Item is null');
      return;
    }
    final id = item['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title" : title,
      "description" : description,
      "is_completed" : false,
    };
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      titleController.text = '';
      descriptionController.text = '';
      print(response.body);
      statusMessage('Əlavə edildi');
    } else {
      print('Error');
      print(response.body);
      statusMessage('Xəta!');
    }
  }

  Future<void> sendData() async {
    // get data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    // send data to the server
    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    // show status message
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      print(response.body);
      statusMessage('Əlavə edildi');
    } else {
      print('Error');
      print(response.body);
      statusMessage('Xəta!');
    }
  }

  void statusMessage(String message) {
    final snackBar = SnackBar(
      padding: const EdgeInsets.all(15),
      content: Text(
        message,
        style: TextStyle(
          color: message == 'Əlavə edildi'? Colors.black : Colors.white,
        ),
      ),
      backgroundColor: message == 'Əlavə edildi' ? Colors.white : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
