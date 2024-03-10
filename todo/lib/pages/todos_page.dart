import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/models/todo_list.dart';
import 'package:todo/services/database_service.dart';
import 'package:todo/pages/edit_todo_page.dart';

// DOTN TOUCH

class TodosPage extends StatelessWidget {
  final TodoList todoList;
  final DatabaseService _databaseService = DatabaseService();

  TodosPage({Key? key, required this.todoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todoList.name), // Display todo list name
      ),
      resizeToAvoidBottomInset: false,
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Adjust the bottom padding as needed
        child: _buildMessagesListView(context),
      ),
    );
  }

  Widget _buildMessagesListView(BuildContext context) {
    return StreamBuilder(
      stream: _databaseService.getTodosOfList(todoList.id),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final data = snapshot.data;
        final TodoList todoListttt;
        if (data!.exists) {
          todoListttt = TodoList.fromJson(data.data() as Map<String, dynamic>);
          // Now you can use the todoList object to build your UI
        } else {
          return const Text('Document does not exist');
        }

        if (todoListttt.todos.isEmpty) {
          return const Center(child: Text("Add a todo!"));
        }
        List<Todo> lastVTodos = todoListttt.todos;
        lastVTodos.sort((a, b) => a.order!.compareTo(b.order!));
        return ReorderableListView.builder(
          itemCount: lastVTodos.length,
          itemBuilder: (context, index) {
            Todo todo = lastVTodos[index];
            String? todoId = lastVTodos[index].id;

            Color backgroundColor;
            if (todo.priority == "HIGH") {
              backgroundColor = Colors.red;
            } else if (todo.priority == "NORMAL") {
              backgroundColor = Colors.yellow; // or any lighter color
            } else {
              backgroundColor = Colors.lightGreen; // or any lighter color
            }

            return Dismissible(
              key: Key(todoId),
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
                    MaterialPageRoute(builder: (context) => EditTodoPage(todo: todo)),
                  );
                  if (updatedTodo != null) {
                    _databaseService.updateTodoInList(todoList.id, updatedTodo);
                  }
                  return false; // Do not dismiss immediately
                } else if (direction == DismissDirection.endToStart) {
                  _databaseService.deleteTodoFromList(todoList.id, todo.id);
                  return true; // Allow the dismiss
                }
                return false; // Return false if dismiss should not be allowed
              },
              child: GestureDetector(
                onTap: () async {
                  final updatedTodo = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditTodoPage(todo: todo)),
                  );
                  if (updatedTodo != null) {
                    // Update the todo with the changes
                    _databaseService.updateTodoInList(todoList.id, updatedTodo);
                  }
                },
                child: Container(
                  color: backgroundColor,
                  child: ListTile(
                    title: Text(todo.task, style: const TextStyle(fontWeight: FontWeight.bold),),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        Todo updatedTodo = todo.copyWith(
                          isDone: !todo.isDone,
                        );
                        _databaseService.updateTodoInList(todoList.id, updatedTodo);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) async {
            if (oldIndex > newIndex) {
              for (int i = newIndex; i < oldIndex; i++) {
                await _databaseService.updateTodoInList(
                    todoList.id, lastVTodos[i].copyWith(order: lastVTodos[i].order! + 1));
              }
            } else {
              newIndex--;
              for (int i = oldIndex + 1; i < newIndex + 1; i++) {
                await _databaseService.updateTodoInList(
                    todoList.id, lastVTodos[i].copyWith(order: lastVTodos[i].order! - 1));
              }
            }
            await _databaseService.updateTodoInList(
                todoList.id, lastVTodos[oldIndex].copyWith(order: newIndex));
          },
        );
      },
    );
  }

  void _displayTextInputDialog(BuildContext context) async {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedPriority = "NORMAL"; // Default priority

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new todo:'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Set maximum height for content
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'Todo name',
                      hintText: 'Enter todo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: null, // Allow multiline
                    keyboardType: TextInputType.multiline, // Enable multiline input
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter description',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    onChanged: (String? value) {
                      if (value != null) {
                        selectedPriority = value;
                      }
                    },
                    items: ["LOW", "NORMAL", "HIGH"]
                        .map((priority) => DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTask = taskController.text.trim();
                String newDescription = descriptionController.text.trim();
                if (newTask.isNotEmpty) {
                  Todo newTodo = Todo(
                    task: newTask,
                    description: newDescription,
                    priority: selectedPriority,
                    isDone: false,
                  );
                  _databaseService.addTodoToList(todoList.id, newTodo);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
