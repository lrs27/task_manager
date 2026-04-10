import 'package:cloud_firestore/cloud_firestore.dart';
import '../modals/task.dart';

class TaskService {
  final CollectionReference _tasksRef = FirebaseFirestore.instance.collection(
    'tasks',
  );

  // ───────────────────────────────────────────────
  // CREATE — Add a new task
  // ───────────────────────────────────────────────
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _tasksRef.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ───────────────────────────────────────────────
  // READ — Stream all tasks in real time
  // ───────────────────────────────────────────────
  Stream<List<Task>> streamTasks() {
    return _tasksRef.orderBy('createdAt', descending: false).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // ───────────────────────────────────────────────
  // UPDATE — Update any field using copyWith()
  // ───────────────────────────────────────────────
  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  // ───────────────────────────────────────────────
  // DELETE — Remove a task
  // ───────────────────────────────────────────────
  Future<void> deleteTask(String id) async {
    await _tasksRef.doc(id).delete();
  }

  // ───────────────────────────────────────────────
  // Toggle isCompleted in Firestore
  // ───────────────────────────────────────────────
  Future<void> toggleTask(Task task) async {
    await _tasksRef.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  // ───────────────────────────────────────────────
  // SUBTASK HELPERS (optional but recommended)
  // ───────────────────────────────────────────────
  Future<void> addSubtask(Task task, String subtask) async {
    if (subtask.trim().isEmpty) return;

    final updated = List<String>.from(task.subtasks)..add(subtask.trim());
    await updateTask(task.copyWith(subtasks: updated));
  }

  Future<void> removeSubtask(Task task, int index) async {
    final updated = List<String>.from(task.subtasks)..removeAt(index);
    await updateTask(task.copyWith(subtasks: updated));
  }
}
