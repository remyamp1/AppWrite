import 'package:flutter/material.dart';
import 'package:todoappwrite/appwrite_service.dart';
import 'package:todoappwrite/todo_model.dart';

class TODOScreen extends StatefulWidget {
  const TODOScreen({super.key});

  @override
  State<TODOScreen> createState() => _TODOScreenState();
}

class _TODOScreenState extends State<TODOScreen> {
  late AppwriteService _appwriteService;
  late List<Task> _tasks;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _appwriteService = AppwriteService();
    _tasks = [];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _appwriteService.getTasks();
      setState(() {
        _tasks = tasks.map((e) => Task.fromDocument(e)).toList();
      });
    } catch (e) {
      print('Error loading tasks:$e');
    }
  }

  Future<void> _addTask() async {
    final title = _controller.text;
    if (title.isNotEmpty) {
      try {
        await _appwriteService.addTask(title);
        _controller.clear();
        _loadTasks();
      } catch (e) {
        print("Error adding task:$e");
      }
    }
  }

  Future<void> _updateTaskStatus(Task task) async {
    try {
      final updatedTask =
          await _appwriteService.updateTaskStatus(task.id, !task.completed);
      setState(() {
        task.completed != updatedTask.data['completed'];
      });
    } catch (e) {
      print("Error updating task:$e");
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _appwriteService.deleteTask(taskId);
      _loadTasks();
    } catch (e) {
      print("Error  deleting task:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO APP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              width: 300,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), label: Text("Add Task")),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(onPressed: _addTask, child: Text("Add Task")),
            Expanded(
                child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _updateTaskStatus(task),
                        ),
                        onLongPress: () => _deleteTask(task.id),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
