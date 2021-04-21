/// Database access and storage implementation
/// Implemented based on sqlite3 database
/// Currently supports only for Windows Desktop

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

/// Get sqlite3 dynamic library
DynamicLibrary _openOnWindows() {
  File dllFile;
  if (kDebugMode) {
    dllFile = File(
        '${Directory.current.path}\\build\\windows\\runner\\Debug\\sqlite3.dll');
  } else {
    dllFile = File('${Directory.current.path}\\sqlite3.dll');
  }
  return DynamicLibrary.open(dllFile.path);
}

void openAndCloseDb() {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  final db = sqlite3.openInMemory();
  db.dispose();
}

Database getSQLiteDatabase(String filePath) {
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
  return sqlite3.open(filePath);
}
