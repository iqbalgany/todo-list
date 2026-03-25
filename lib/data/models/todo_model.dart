// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final bool isDone;
  final String userId;
  final DateTime dueDate;
  final DateTime? createdAt;
  TodoModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.userId,
    required this.dueDate,
    this.createdAt,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? userId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'isDone': isDone,
      'userId': userId,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TodoModel(
      id: documentId,
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      userId: map['userId'] as String? ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  bool operator ==(covariant TodoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.isDone == isDone &&
        other.userId == userId &&
        other.dueDate.isAtSameMomentAs(dueDate);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isDone.hashCode ^
        userId.hashCode ^
        dueDate.hashCode;
  }
}
