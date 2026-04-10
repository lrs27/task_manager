import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modals/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const TaskListScreen({super.key, required this.onToggleTheme});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TaskService _taskService = TaskService();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Real-time search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // Add a new task
  // ───────────────────────────────────────────────
  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    await _taskService.addTask(text);
    _taskController.clear();
  }

  // ───────────────────────────────────────────────
  // Add subtask dialog
  // ───────────────────────────────────────────────
  Future<void> _showAddSubtaskDialog(Task task) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Subtask"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Subtask name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await _taskService.addSubtask(task, text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Confirm delete
  // ───────────────────────────────────────────────
  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text("Are you sure you want to delete '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _taskService.deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          // ── Add Task Row ──────────────────────────────────────────
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

          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Firestore StreamBuilder ─────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                // Convert to Task objects
                var tasks = docs
                    .map(
                      (d) =>
                          Task.fromMap(d.id, d.data() as Map<String, dynamic>),
                    )
                    .toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  tasks = tasks
                      .where(
                        (t) => t.title.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                // Empty state
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks found — try adding one!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Render tasks
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1,
                      child: ExpansionTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _taskService.toggleTask(task),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(task),
                        ),

                        // ── Subtasks ─────────────────────────────
                        children: [
                          ...task.subtasks.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final sub = entry.value;

                            return ListTile(
                              dense: true,
                              title: Text(sub),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _taskService.removeSubtask(task, idx),
                              ),
                            );
                          }),

                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add subtask"),
                            onPressed: () => _showAddSubtaskDialog(task),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
