/// Database access and storage implementation
/// Implemented based on sqlite3 database
/// Currently supports only for Windows Desktop

import 'dart:collection';

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

import 'data_structures.dart';

/// get the directory where executable is located
///
/// Gets the build directory in windows, when in debug mode.
/// Returns the directory of executable when executable is run directly
String getFilesDirectory() {
  if (kDebugMode) {
    return '${Directory.current.path}\\build\\windows\\runner\\Debug';
  } else {
    return '${Directory.current.path}';
  }
}

/// The class for storing database related methods. Also used with provider
/// package for state management of the app.
class DatabaseProvider extends ChangeNotifier {
  DatabaseStatus _status = DatabaseStatus.NotLoaded;
  var _tasksList = <TaskItem>[];

  get dbStatus => _status;
  set dbStatus(DatabaseStatus s) {
    _status = s;
    notifyListeners();
  }

  List<TaskItem> get tasks => UnmodifiableListView(_tasksList);

  DatabaseProvider() {
    // change default sqlite3 dll loading behaviour for windows.
    // This allows the use of dll shipped along with executable
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
  }

  /// Get dynamic library for sqlite3
  DynamicLibrary _openOnWindows() {
    File dllFile;
    final filesDir = getFilesDirectory();
    dllFile = File('$filesDir\\sqlite3.dll');
    return DynamicLibrary.open(dllFile.path);
  }

  /// load tasks from database and notify listeners
  ///
  /// Used for loading the task details into flutter widgets
  /// After each operation in database, ensure to reload tasks
  /// to update the user interface
  void loadTasks() {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readOnly,
    );

    final resultSet = db.select('''SELECT * FROM TASKS''');
    _tasksList.clear();
    resultSet.forEach((row) {
      _tasksList.add(TaskItem(
          id: row['task_id'],
          name: row['name'],
          status: row['status'] == 'completed'
              ? TaskItemStatus.Completed
              : TaskItemStatus.Pending));
    });
    notifyListeners();
  }

  /// Add new task to database and set it's status to `pending`
  void addNewTask({String name}) {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readWrite,
    );

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final stmt = db.prepare(
        'INSERT INTO tasks (name, status, createdon) VALUES (?, "pending", ?)');
    stmt.execute([name, currentTime]);
    stmt.dispose();
    db.dispose();
  }

  /// Delete an existing task from database
  void deleteTask({int taskId}) {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readWrite,
    );

    final stmt = db.execute('DELETE FROM tasks WHERE task_id="$taskId"');
    db.dispose();
  }

  /// Set the task status to either `completed` or `pending`
  void setTaskStatus({int taskId, TaskItemStatus status}) {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readWrite,
    );

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (status == TaskItemStatus.Completed) {
      db.execute('''UPDATE tasks 
      SET 
        status="completed",
        completedon=$currentTime,
        modifiedon=$currentTime
        WHERE task_id=$taskId''');
    } else if (status == TaskItemStatus.Pending) {
      db.execute('''UPDATE tasks 
          SET 
            status="pending", 
            completedon="NULL", 
            modifiedon=$currentTime 
          WHERE 
            task_id=$taskId''');
    }
    db.dispose();
  }

  /// check if database file exists and return a boolean future
  static Future<bool> checkIfDatabaseExists() async {
    File dbFile = File('${getFilesDirectory()}\\tasking.db');
    if (await dbFile.exists()) {
      return true;
    }
    return false;
  }

  /// Create a new database file if file doesnot exists and create tables
  /// in the db file.
  static createDatabase() {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readWriteCreate,
    );

    final sqlCreateTasksTable = """
      CREATE TABLE TASKS (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        status VARCHAR(50),
        createdon INTEGER,
        modifiedon INTEGER,
        completedon INTEGER
      )
    """;
    db.execute(sqlCreateTasksTable);
    db.dispose();
  }
}

/// Enum containing list of allowed database loading status.
enum DatabaseStatus { Loaded, NotLoaded, FileMissing }
