import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/features/home_page/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._internal();

  final String _tblName = 'tasks';
  final String _colId = 'id';
  final String _colTask = 'task';
  final String _colStatus = 'status';

  DatabaseServices._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final dbDirPath = await getDatabasesPath();
    final dbpath = join(dbDirPath, 'master_db.db');
    final db = await openDatabase(
      dbpath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_tblName (
          $_colId INTEGER PRIMARY KEY,
          $_colTask TEXT NOT NULL,
          $_colStatus INTEGER NOT NULL
        )

      ''');
      },
    );
    return db;
  }

  void updateTaskstatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tblName,
      {
        _colStatus: status,
      },
      where: '$_colId = ?',
      whereArgs: [
        id,
      ],
    );
  }

  void insertTask(String content) async {
    try {
      final db = await database;
      await db.insert(
        _tblName,
        {
          _colTask: content,
          _colStatus: 0,
        },
      );
      Get.snackbar('Task Added', 'Successfully Inserted task');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tblName);

    return List.generate(maps.length, (i) {
      return TaskModel(
        id: maps[i][_colId],
        task: maps[i][_colTask],
        status: maps[i][_colStatus],
      );
    });
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(_tblName, where: '$_colId = ?', whereArgs: [id]);
    Get.snackbar('Task Deleted', 'Successfully Deleted task');
  }
}
