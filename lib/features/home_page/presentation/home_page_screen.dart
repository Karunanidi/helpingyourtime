import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:helpyourtime/components/custom_text.dart';
import 'package:helpyourtime/components/my_text_field.dart';
import 'package:helpyourtime/features/home_page/models/task_model.dart';
import 'package:helpyourtime/services/database_services.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final DatabaseServices databaseServices = DatabaseServices.instance;
  final TextEditingController taskEditingController = TextEditingController();
  final ValueNotifier<List<TaskModel>> _taskNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    // _checkPermissions();
    _loadTasks();
  }

  ///=================== CHECK PERMISSION ===================

  // Future<void> _checkPermissions() async {
  //   // Check for storage permission
  //   PermissionStatus status = await Permission.storage.status;
  //   if (status.isDenied || status.isPermanentlyDenied) {
  //     status = await Permission.storage.request();
  //     if (status.isDenied) {
  //       _showPermissionDeniedDialog();
  //     } else if (status.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //   }
  // }

  // void _showPermissionDeniedDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const CustomText(
  //         text: 'Permission Denied',
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       content: const CustomText(
  //         text: 'Storage permission is required to use this app.',
  //         fontSize: 16,
  //         fontWeight: FontWeight.normal,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text(
  //             'OK',
  //             style: TextStyle(color: Colors.black),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  ///=================== LOAD TASKS ===================
  Future<void> _loadTasks() async {
    final tasks = await databaseServices.getTasks();
    _taskNotifier.value = tasks;
  }

  ///=================== INSERT TASK ===================
  void _insertTask() {
    if (taskEditingController.text.isEmpty) return;
    databaseServices.insertTask(taskEditingController.text);
    taskEditingController.clear();
    Navigator.of(context).pop();
    _loadTasks();
  }

  ///=================== DELETE TASK ===================
  void _deleteTask(int id) {
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              databaseServices.deleteTask(id);
              Navigator.of(context).pop();
              _loadTasks();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  ///=================== UPDATE TASK STATUS ===================
  void _updateTaskStatus(int id, bool isCompleted) {
    databaseServices.updateTaskstatus(id, isCompleted ? 1 : 0);
    _loadTasks();
  }

  @override
  void dispose() {
    taskEditingController.dispose();
    _taskNotifier.dispose();
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

  ///=================== ADD TASK BUTTON ===================
  Widget get _addTaskButton => FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const CustomText(
                text: 'Add Task',
              ),
              backgroundColor: Colors.white,
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    taskEditingController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: _insertTask,
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      );

  ///=================== TASK LIST ===================
  Widget _taskList() {
    return ValueListenableBuilder<List<TaskModel>>(
      valueListenable: _taskNotifier,
      builder: (context, tasks, _) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found'));
        } else {
          return RefreshIndicator(
            onRefresh: _loadTasks,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                TaskModel task = tasks[index];
                return Slidable(
                  key: ValueKey(task.id),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _deleteTask(task.id);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      task.task,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    trailing: ValueListenableBuilder<bool>(
                      valueListenable: ValueNotifier(task.status == 1),
                      builder: (context, isCompleted, _) {
                        return Checkbox(
                          value: isCompleted,
                          onChanged: (value) {
                            _updateTaskStatus(task.id, value!);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
