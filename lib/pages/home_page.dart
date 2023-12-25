import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todoapp/pages/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp/services/todo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Ediləcəklər siyahısı')),
        backgroundColor: Color(0xFF5C8374),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('Əlavə et'),
        ),
        backgroundColor: Color(0xFF5C8374),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: const Center(
            child: Text(
              'Ediləcək bir şey yoxdur.',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final id = item['_id'] as String;
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${index + 1}',
                      ),
                      backgroundColor: Color(0xFF5C8374),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Open Edit Page
                          navigateToEditPage(item);
                        } else if (value == 'delete') {
                          // Delete and Refresh
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text('Düzəliş et'),
                            value: 'edit',
                          ),
                          const PopupMenuItem(
                            child: Text('Sil'),
                            value: 'delete',
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddPage(),
    );
    await Navigator.push(context, route);
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(item: item),
    );
    await Navigator.push(context, route);
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // Delete the item
    final isSuccess = await ToDoService.deleteById(id);
    if (isSuccess) {
      // Remove the item from the list
      final afterDelete =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = afterDelete;
      });
    } else {
      // Show Status
      statusMessage('Xəta!');
    }
  }

  void statusMessage(String message) {
    final snackBar = SnackBar(
      padding: const EdgeInsets.all(15),
      content: Text(
        message,
        style: TextStyle(
          color: message == 'Əlavə edildi' ? Colors.black : Colors.white,
        ),
      ),
      backgroundColor: message == 'Əlavə edildi' ? Colors.white : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> fetchTodo() async {
    final response = await ToDoService.fetchTodos();

    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      statusMessage('Xəta');
    }
  }
}
