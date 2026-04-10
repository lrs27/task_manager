import 'package:flutter/material.dart';
import '../modals/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void dispose() {
    _taskController.dispose(); // Prevent memory leaks
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // Add a new task to the list
  // ───────────────────────────────────────────────
  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text,
      isCompleted: false,
      subtasks: [],
      createdAt: DateTime.now(),
    );

    setState(() {
      _tasks.add(newTask);
    });

    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          // ── Input Row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'New task name...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),

          // ── Task List ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(title: Text(task.title));
              },
            ),
          ),
        ],
      ),
    );
  }
}
