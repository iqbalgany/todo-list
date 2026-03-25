import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/data/models/todo_model.dart';

class TodoRemoteDatasource {
  String uid;
  final _db = FirebaseFirestore.instance;

  TodoRemoteDatasource({required this.uid});

  CollectionReference<TodoModel> get _todosRef {
    return _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .withConverter<TodoModel>(
          fromFirestore: (snapshot, _) =>
              TodoModel.fromMap(snapshot.data()!, snapshot.id),
          toFirestore: (todo, _) => todo.toMap(),
        );
  }

  // Read all todos
  Stream<List<TodoModel>> get todos {
    return _todosRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Create a todo
  Future<void> addTodo(String title, DateTime? dueDate) async {
    if (uid.isEmpty) {
      throw Exception('Gagal menambah data: User ID tidak ditemukan (Kosong)');
    }
    try {
      await _todosRef.add(
        TodoModel(
          id: '',
          title: title,
          isDone: false,
          userId: uid,
          dueDate: dueDate ?? DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('Failed to add data: $e');
    }
  }

  // Edit the todo
  Future<void> updateTodo(String id, String title, DateTime? dueDate) async {
    try {
      await _todosRef.doc(id).update({
        'title': title,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      });
    } catch (e) {
      throw Exception('Data update failed: $e');
    }
  }

  // Update todo status
  Future<void> updateTodoStatus(String id, bool isDone) async {
    try {
      await _todosRef.doc(id).update({'isDone': isDone});
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    try {
      await _todosRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}
