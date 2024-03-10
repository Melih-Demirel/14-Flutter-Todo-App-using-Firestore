import 'package:flutter/material.dart';
import 'package:todo/models/todo_list.dart';
import 'package:todo/pages/todos_page.dart';
import 'package:todo/services/database_service.dart';

import 'edit_todoList_page.dart';
// DONT TOUCH

class TodosListsPage extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Lists'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(context),
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: _databaseService.getTodoLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List todoLists = snapshot.data?.docs ?? [];
          List todosS = todoLists.map((snapshot) {
            TodoList todo = snapshot.data();
            todo.id = snapshot.id;
            return todo;
          }).toList();
          if (todoLists.isEmpty) {
            return Center(child: Text('No todo lists found'));
          }

          return ListView.builder(
            itemCount: todoLists.length,
            itemBuilder: (context, index) {
              final TodoList todoList = todosS[index];
              return Dismissible(
                key: Key(todoList.id), // Use a unique key for each item
                background: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Edit
                    final updatedTodo = await Navigator.push(
                      context,
                      MaterialPageRoute(builder:
                          (context) => EditTodoListPage(todoList: todoList)),
                    );
                    if (updatedTodo != null) {
                      _databaseService.updateTodoList(updatedTodo);
                    }
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    // Swipe left (delete)
                    _databaseService.deleteTodoList(todoList.id);
                    return true; // Allow the dismiss
                  }
                  return false; // Allow the dismiss
                },
                child: ListTile(
                  title: Text(todoList.name, style: const TextStyle(fontWeight: FontWeight.bold),),
                  onTap: () {
                    // Navigate to the todos page for this todo list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodosPage(todoList: todoList),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayDialog(BuildContext context) async {
    final TextEditingController textEditingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a new todo list:'),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(hintText: 'Enter list name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newListName = textEditingController.text.trim();
                if (newListName.isNotEmpty) {
                  _databaseService.addTodoList(TodoList(name: newListName, todos: []));
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
