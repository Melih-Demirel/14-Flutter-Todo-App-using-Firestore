import 'dart:math';
import 'package:todo/utils/helpers.dart';

class Todo {
  String id;
  String task;
  String description;
  String priority;
  bool isDone;
  int? order; // Nullable order field

  Todo({
    required this.task,
    required this.isDone,
    required this.description,
    required this.priority,
    this.order,
    String? id, // Removed id from constructor parameters
  }) : id = id ?? generateUuid(); // Generate UUID if id is not provided

  factory Todo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to load todo data');
    }
    return Todo(
      id: json['id'] as String? ?? generateUuid(), // Generate UUID if id is not present in JSON
      task: json['task'] as String,
      description: json['description'] as String,
      isDone: json['isDone'] as bool,
      priority: json['priority'] as String,
      order: json['order'] as int?,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'task': task,
    'isDone': isDone,
    'order': order,
    'description': description,
    'priority': priority,
  };

  Todo copyWith({
    String? id,
    String? task,
    bool? isDone,
    int? order,
    String? description,
    String? priority,
  }) =>
      Todo(
        id: id ?? this.id,
        task: task ?? this.task,
        isDone: isDone ?? this.isDone,
        order: order ?? this.order,
        description: description ?? this.description,
        priority: priority ?? this.priority,
      );

  // static String _generateUuid() {
  //   final random = Random();
  //   final sb = StringBuffer();
  //   for (var i = 0; i < 32; i++) {
  //     final hex = (random.nextInt(16)).toRadixString(16);
  //     sb.write(hex);
  //   }
  //   return sb.toString();
  // }
}
