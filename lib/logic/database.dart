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

/// Enum containing list of allowed database loading status.
enum DatabaseStatus { Loaded, NotLoaded, FileMissing }

/// Enum of database related operations by application
enum DatabaseOps { TaskAdded, TaskUpdated, TaskDeleted }

/// The class for storing database related methods. Also used with provider
/// package for state management of the app.
class DatabaseProvider extends ChangeNotifier {
  DatabaseStatus _status = DatabaseStatus.NotLoaded;

  get dbStatus => _status;
  set dbStatus(DatabaseStatus s) {
    _status = s;
    notifyListeners();
  }

  DatabaseOps _lastOp;

  get lastOp => _lastOp;
  set lastOp(DatabaseOps op) {
    _lastOp = op;
    notifyListeners();
  }
}

class DatabaseAccess {
  DatabaseAccess() {
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

  /// Add new task to database and set it's status to `pending`
  static void addNewTask({String name}) {
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
  static void deleteTask({int taskId}) {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readWrite,
    );

    db.execute('DELETE FROM tasks WHERE task_id="$taskId"');
    db.dispose();
  }

  /// Set the task status to either `completed` or `pending`
  static void setTaskStatus({int taskId, TaskItemStatus status}) {
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
            completedon=NULL, 
            modifiedon=$currentTime 
          WHERE 
            task_id=$taskId''');
    }
    db.dispose();
  }

  static List<TaskItem> getTasks(TaskMenuItemTag filter) {
    final db = sqlite3.open(
      '${getFilesDirectory()}\\tasking.db',
      mode: OpenMode.readOnly,
    );

    var qry = '''SELECT * FROM TASKS''';

    if (filter == TaskMenuItemTag.Completed) {
      qry = '''SELECT * FROM TASKS WHERE status ="completed" ''';
    } else if (filter == TaskMenuItemTag.Planned) {
      qry = '''SELECT * FROM TASKS WHERE status ="pending"''';
    }

    final resultSet = db.select(qry);
    var tasksList = <TaskItem>[];
    resultSet.forEach((row) {
      tasksList.add(TaskItem(
          id: row['task_id'],
          name: row['name'],
          status: row['status'] == 'completed'
              ? TaskItemStatus.Completed
              : TaskItemStatus.Pending));
    });

    return tasksList;
  }
}
