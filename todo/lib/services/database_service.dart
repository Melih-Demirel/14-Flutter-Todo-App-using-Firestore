import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/models/todo_list.dart'; // Import your TodoList class

const String TODO_COLLECTION_REF = "todos_lists";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _todosRef;

  DatabaseService() {
    _todosRef = _firestore.collection(TODO_COLLECTION_REF).withConverter<TodoList>(
      fromFirestore: (snapshots, _) => (TodoList.fromJson(
        snapshots.data()!,
      )),
      toFirestore: (todoList, _) => todoList.toJson());
  }

  Stream<QuerySnapshot> getTodoLists() {
    return _todosRef.snapshots();
  }

  Future<void> addTodoList(TodoList todoList) async {
    await _todosRef.add(todoList);
  }

  Future<void> updateTodoList(TodoList todoList) async {
    await _todosRef.doc(todoList.id).update(todoList.toJson());
  }

  Future<void> deleteTodoList(String todoListId) async {
    await _todosRef.doc(todoListId).delete();
  }

  Stream<DocumentSnapshot> getTodosOfList(String todoListId) {
    return _firestore.collection("todos_lists").doc(todoListId).snapshots();
  }

  Future<void> addTodoToList(String todoListId, Todo todo) async {

    final DocumentSnapshot<TodoList> todoListSnapshot = await _todosRef.doc(todoListId).get() as DocumentSnapshot<TodoList>;
    if(todoListSnapshot.exists){
      // Get the todos list from the document
      final List<Todo> todos = todoListSnapshot.data()?.todos ?? [];
      // Get the number of todos
      final int numberOfTodos = todos.length;
      todo.order = numberOfTodos;
    }
    await _todosRef.doc(todoListId).update({
      'todos': FieldValue.arrayUnion([todo.toJson()]),
    });
  }


  Future<void> updateTodoInList(String todoListId, Todo todo) async{
     DocumentSnapshot<TodoList> todoListSnapshot =
        await _todosRef.doc(todoListId).get() as DocumentSnapshot<TodoList>;
        if (todoListSnapshot.exists) {
          // Get the todos list from the document
          List<Todo> todos = todoListSnapshot.data()?.todos ?? [];
          // Find the index of the todo to update
          int todoIndex = todos.indexWhere((t) => t.id == todo.id);

          if (todoIndex != -1) {
            // Replace the todo at the found index with the updated todo
            todos[todoIndex] = todo;
            await _todosRef.doc(todoListId).update({
              'todos': todos.map((t) => t.toJson()).toList(),
            });
          } else {
            print("Todo not found in the list.");
          }
        } else {
          print("Todo list not found.");
        }
  }
  Future<void> deleteTodoFromList(String todoListId, String todoId) async{
    DocumentSnapshot<TodoList> todoListSnapshot =
    await _todosRef.doc(todoListId).get() as DocumentSnapshot<TodoList>;
    if (todoListSnapshot.exists) {
      // Get the todos list from the document
      List<Todo> todos = todoListSnapshot.data()?.todos ?? [];
      todos.sort((a, b) => a.order!.compareTo(b.order!));
      // Find the index of the todo to update
      int toRemoveIndex = todos.indexWhere((t) => t.id == todoId);

      final lenTodos = todos.length;

      if (toRemoveIndex != -1) {
        // Replace the todo at the found index with the updated todo
        todos.removeAt(toRemoveIndex);
        if(toRemoveIndex != lenTodos - 1){
          for(int i = toRemoveIndex; i < todos.length; i++){
            todos[i].order = i;
          }
        }

        await _todosRef.doc(todoListId).update({
          'todos': todos.map((t) => t.toJson()).toList(),
        });
      } else {
        print("Todo not found in the list.");
      }
    } else {
      print("Todo list not found.");
    }
  }
  // Future<void> deleteTodoFromList(String todoListId, String todoId) async {
  //   await _todosRef.doc(todoListId).update({
  //     'todos': FieldValue.arrayRemove([{'id': todoId}]),
  //   });
  // }
}
