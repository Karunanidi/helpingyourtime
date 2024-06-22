import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/custom_text.dart';
import 'package:myapp/components/my_text_field.dart';
import 'package:myapp/features/home_page/models/task_model.dart';
import 'package:myapp/services/database_services.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final DatabaseServices databaseServices = DatabaseServices.instance;
  final TextEditingController taskEditingController = TextEditingController();

  void _insertTask() {
    if (taskEditingController.text.isEmpty) return;
    databaseServices.insertTask(taskEditingController.text);
    taskEditingController.clear();
    Navigator.of(context).pop();
    setState(() {}); // To refresh the task list after insertion
  }

  void _deleteTasks(int id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      databaseServices.deleteTask(id);
                      setState(
                          () {}); // To refresh the task list after deletion
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  void dispose() {
    taskEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Timytime',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _taskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _addTaskButton,
    );
  }

  Widget get _addTaskButton => FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const CustomText(
                text: 'Add Task',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                    controller: taskEditingController,
                    hintText: 'Enter task',
                    obscureText: false,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _insertTask,
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    taskEditingController.clear();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      );

  Widget _taskList() {
    return FutureBuilder<List<TaskModel>>(
      future: databaseServices.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              TaskModel task = snapshot.data![index];
              return ListTile(
                onLongPress: () {
                  // show confirmation dialog
                  _deleteTasks(task.id);
                },
                title: AutoSizeText(
                  task.task,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Checkbox(
                  value: task.status == 1,
                  onChanged: (value) {
                    databaseServices.updateTaskstatus(
                        task.id, value == true ? 1 : 0);
                    setState(() {});
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
