import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<String> subtasks;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.subtasks,
    this.createdAt,
  });

  // -----------------------------
  // copyWith() — update safely
  // -----------------------------
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<String>? subtasks,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // -----------------------------
  // toMap() — Firestore write
  // -----------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'createdAt': createdAt,
    };
  }

  // -----------------------------
  // fromMap() — Firestore read
  // -----------------------------
  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: List<String>.from(map['subtasks'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
