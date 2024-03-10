import 'package:todo/utils/helpers.dart';

import 'todo.dart'; // Import your Todo class

class TodoList {
  String id;
  String name;
  List<Todo> todos;


  TodoList({
    required this.name,
    required this.todos,
    String? id, // Removed id from constructor parameters
  }) : id = id ?? generateUuid(); // Generate UUID if id is not provided

  factory TodoList.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to load todo data');
    }
    return TodoList(
      id: json['id'] as String? ?? generateUuid(),
      name: json['name'] as String,
      todos: (json['todos'] as List<dynamic>).map((todo) => Todo.fromJson(todo)).toList(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'todos': todos.map((todo) => todo.toJson()).toList(),
    };
  }

  TodoList copyWith({
    String? id,
    String? name,
    List<Todo>? todos,
    // Timestamp? timestamp,
  }) =>
      TodoList(
        id : id ?? this.id,
        name: name ?? this.name,
        todos: todos ?? this.todos,
      );
}


