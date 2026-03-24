import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_list/data/models/todo_model.dart';
import 'package:todo_list/data/remote_datasources/todo/todo_remote_datasource.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRemoteDatasource _todo;
  StreamSubscription? _todoSubscription;
  TodoCubit(this._todo) : super(const TodoState());

  void updateUiandFetch(String newUid) {
    _todo.uid = newUid;
    getTodos();
  }

  void getTodos() {
    emit(state.copyWith(status: TodoStatus.loading));

    _todoSubscription?.cancel();

    _todoSubscription = _todo.todos.listen(
      (todosList) {
        emit(state.copyWith(status: TodoStatus.success, todos: todosList));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TodoStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> addTodo(String title, DateTime? dueDate) async {
    try {
      await _todo.addTodo(title, dueDate);
    } catch (e) {
      emit(
        state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleStatus(String id, bool currentStatus) async {
    try {
      await _todo.updateTodoStatus(id, !currentStatus);
    } catch (e) {
      emit(
        state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      await _todo.deleteTodo(id);
    } catch (e) {
      emit(
        state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _todoSubscription?.cancel();
    return super.close();
  }
}
