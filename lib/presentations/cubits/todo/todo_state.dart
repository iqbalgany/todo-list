// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'todo_cubit.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  final List<TodoModel> todos;
  final TodoStatus status;
  final String errorMessage;
  const TodoState({
    this.todos = const [],
    this.status = TodoStatus.initial,
    this.errorMessage = '',
  });

  @override
  List<Object> get props => [todos, status, errorMessage];

  TodoState copyWith({
    List<TodoModel>? todos,
    TodoStatus? status,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
