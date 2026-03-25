import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/core/themes/colors.dart';
import 'package:todo_list/data/models/todo_model.dart';
import 'package:todo_list/presentations/cubits/auth/auth_cubit.dart';
import 'package:todo_list/presentations/cubits/todo/todo_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) {
      context.read<TodoCubit>().updateUiandFetch(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState.user != null) {
          context.read<TodoCubit>().updateUiandFetch(authState.user!.uid);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Todos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, todoState) {
            if (todoState.status == TodoStatus.loading &&
                todoState.todos.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            if (todoState.status == TodoStatus.failure) {
              return Center(child: Text('Error ${todoState.errorMessage}'));
            }

            if (todoState.todos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_add,
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Todos yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }

            final todos = todoState.todos;

            final pendingTodos = todos.where((todo) => !todo.isDone).toList();
            final completeTodos = todos.where((todo) => todo.isDone).toList();

            return CustomScrollView(
              slivers: [
                if (pendingTodos.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Pending Tasks: ${pendingTodos.length}',
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildTodoItem(context, pendingTodos[index]),
                        childCount: pendingTodos.length,
                      ),
                    ),
                  ),
                ],

                if (completeTodos.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Complete Tasks: ${completeTodos.length}',
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildTodoItem(context, completeTodos[index]),
                        childCount: completeTodos.length,
                      ),
                    ),
                  ),
                ],

                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showTodoDialog(context, null);
          },
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showTodoDialog(BuildContext context, TodoModel? todo) {
    final bool isEditing = todo != null;
    final TextEditingController titleController = TextEditingController(
      text: todo?.title ?? '',
    );
    DateTime? selectDate = todo?.dueDate;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: isEditing
                          ? 'Enter todo title'
                          : 'What needs to be done?',

                      prefixIcon: Icon(
                        isEditing
                            ? Icons.edit_outlined
                            : Icons.check_circle_outline,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        initialDate: selectDate ?? DateTime.now(),
                      );

                      if (picked != null && picked != selectDate) {
                        setState(() {
                          selectDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectDate == null
                              ? Colors.transparent
                              : AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,

                            size: 20,
                            color: selectDate == null
                                ? AppColors.textSecondary
                                : AppColors.primary,
                          ),
                          SizedBox(width: 12),
                          Text(
                            selectDate == null
                                ? (isEditing
                                      ? 'No Date Chosen'
                                      : 'Set Due Date')
                                : DateFormat('MMM d, yyyy').format(selectDate!),
                            style: TextStyle(
                              color: selectDate == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final authState = context.read<AuthCubit>().state;
                      final userId = authState.user?.uid;

                      if (userId != null && userId.isNotEmpty) {
                        context.read<TodoCubit>().updateUiandFetch(userId);

                        if (isEditing) {
                          context.read<TodoCubit>().editTodo(
                            todo.id,
                            titleController.text.trim(),
                            selectDate,
                          );
                        } else {
                          context.read<TodoCubit>().addTodo(
                            titleController.text.trim(),
                            selectDate,
                          );
                        }
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: Sesi login tidak valid'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTodoItem(BuildContext context, TodoModel todo) {
    final bool isOverdue =
        todo.dueDate.isBefore(DateTime.now()) && !todo.isDone;

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.success,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24),
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.error,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showTodoDialog(context, todo);
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TodoCubit>().removeTodo(todo.id);
        }
      },
      child: Card(
        elevation: 2,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              decorationStyle: TextDecorationStyle.solid,
              decorationThickness: 3,
              color: todo.isDone
                  ? AppColors.textSecondary.withValues(alpha: 0.6)
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isOverdue ? AppColors.error : AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                DateFormat('MMM d, yyyy').format(todo.dueDate),
                style: TextStyle(
                  color: isOverdue ? AppColors.error : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          leading: Checkbox(
            value: todo.isDone,
            activeColor: AppColors.success,
            shape: CircleBorder(),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            onChanged: (_) =>
                context.read<TodoCubit>().toggleStatus(todo.id, todo.isDone),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 24, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
