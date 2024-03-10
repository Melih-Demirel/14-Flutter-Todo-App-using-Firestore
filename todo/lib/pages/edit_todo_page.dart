import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';

// DONT TOUCH WORKING

class EditTodoPage extends StatelessWidget {
  final Todo todo;
  final TextEditingController _taskController;
  final TextEditingController _descriptionController;

  EditTodoPage({required this.todo})
      : _taskController = TextEditingController(text: todo.task),
        _descriptionController = TextEditingController(text: todo.description);

  @override
  Widget build(BuildContext context) {
    String _selectedPriority = todo.priority.toString().split('.').last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(labelText: 'Todo name:'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(labelText: 'Description:'),
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                onChanged: (String? value) {
                  if (value != null) {
                    _selectedPriority = value;
                  }
                },
                items: ["LOW", "NORMAL", "HIGH"]
                    .map((priority) => DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                ))
                    .toList(),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    todo.task = _taskController.text;
                    todo.description = _descriptionController.text;
                    todo.priority = _selectedPriority;
                    Navigator.pop(context, todo);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
