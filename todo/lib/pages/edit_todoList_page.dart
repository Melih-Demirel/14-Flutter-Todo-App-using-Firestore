import 'package:flutter/material.dart';
import 'package:todo/models/todo_list.dart';
// DONT TOUCH
class EditTodoListPage extends StatelessWidget {
  final TodoList todoList;
  final TextEditingController _nameController;

  EditTodoListPage({required this.todoList})
      : _nameController = TextEditingController(text: todoList.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Todo List name:'),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // No need to update the UI since this is stateless
                  todoList.name = _nameController.text;
                  Navigator.pop(context, todoList);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
