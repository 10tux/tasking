/// Database access and storage implementation
/// Implemented based on sqlite3 database
/// Currently supports only for Windows Desktop

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/open.dart';

String getFilesDirectory() {
  if (kDebugMode) {
    return '${Directory.current.path}\\build\\windows\\runner\\Debug';
  } else {
    return '${Directory.current.path}';
  }
}

class DatabaseProvider extends ChangeNotifier {
  DatabaseStatus _status = DatabaseStatus.NotLoaded;

  DatabaseProvider() {
    _overrideDefaultLoadingBehaviour();
  }

  get dbStatus => _status;
  set dbStatus(DatabaseStatus s) {
    _status = s;
    notifyListeners();
  }

  /// Get dynamic library for sqlite3
  DynamicLibrary _openOnWindows() {
    File dllFile;
    final filesDir = getFilesDirectory();
    dllFile = File('$filesDir\\sqlite3.dll');
    return DynamicLibrary.open(dllFile.path);
  }

  /// override default loading behaviour
  void _overrideDefaultLoadingBehaviour() {
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
  }

  /// check if database file exists
  static Future<bool> checkIfDatabaseExists() async {
    File dbFile = File('${getFilesDirectory()}\\tasking.db');
    if (await dbFile.exists()) {
      return true;
    }
    return false;
  }

  static createDatabase() {
    
  }
}

enum DatabaseStatus { Loaded, NotLoaded, FileMissing }

/// Get sqlite3 dynamic library

void openAndCloseDb() {}
