import 'dart:async';

import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../models/data.dart';

class SqlHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    print('database path $dbPath');
    return openDatabase(
      p.join(dbPath, 'sensogrip.db'),
      onCreate: (db, version) => _createDb(db),
      onConfigure: _onConfigure,
      version: 1,
    );
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static void _createDb(Database db) async {
    await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          tipSensorUpperRange INTEGER NOT NULL,
          tipSensorLowerRange INTEGER NOT NULL,
          fingerSensorUpperRange INTEGER NOT NULL,
          fingerSensorLowerRange INTEGER NOT NULL,
          isPositiveFeedback INTEGER NOT NULL,
          feedbackType INTEGER NOT NULL,
          isAIon INTEGER NOT NULL,
          isAngleCorrected INTEGER NOT NULL,
          ledSimpleAssistanceColor INTEGER NOT NULL,
          ledTipAssistanceColor INTEGER NOT NULL,
          ledFingerAssistanceColor INTEGER NOT NULL,
          ledOkColor INTEGER NOT NULL,
          ledNokColor INTEGER NOT NULL
          )''');
    await db.execute('''
        CREATE TABLE data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userid INTEGER NOT NULL,
          username TEXT NOT NULL,
          description TEXT NOT NULL,
          pencilname TEXT NOT NULL,
          measurement TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          FOREIGN KEY(userid) REFERENCES users(id)
          )''');
  }

  static Future<void> deleteTable(String table) async {
    final db = await SqlHelper.database();
    await db.execute('DROP TABLE $table');
    print('Drop table $table');
  }

  static Future<void> deleteDb(String database) async {
    final dbPath = await getDatabasesPath();
    String path = p.join(dbPath, '$database.db');
    deleteDatabase(path);
    print('Delete database $database');
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await SqlHelper.database();
    print('Inserted $data into $table');
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertUser(User user) async {
    final db = await SqlHelper.database();
    print('Inserted ${user.name} into users with data ${user.toMap()}');
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateUser(User user) async {
    final db = await SqlHelper.database();
    print('Updated ${user.name} in users with data ${user.toMap()}');
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertData(Map<String, Object> data) async {
    final db = await SqlHelper.database();
    print('Inserted $data with userid $data[userid] into data');
    await db.insert(
      'data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getTable(String table) async {
    final db = await SqlHelper.database();
    return await db.query(table);
  }

  static Future<Map<String, dynamic>> getUser(int id) async {
    final db = await SqlHelper.database();
    final query = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return query.isNotEmpty ? query[0] : {};
  }

  static Future<List<User>> getUsers() async {
    final db = await SqlHelper.database();
    final usersFromDb = await db.query('users');
    List<User> users = [];
    usersFromDb.forEach(
      (user) {
        users.add(
          User(
            id: user['id'],
            name: user['name'],
            description: user['description'],
            tipSensorUpperRange: user['tipSensorUpperRange'],
            tipSensorLowerRange: user['tipSensorLowerRange'],
            fingerSensorUpperRange: user['fingerSensorUpperRange'],
            fingerSensorLowerRange: user['fingerSensorLowerRange'],
            isPositiveFeedback: user['isPositiveFeedback'],
            feedbackType: user['feedbackType'],
            isAIon: user['isAIon'],
            isAngleCorrected: user['isAngleCorrected'],
            ledSimpleAssistanceColor: user['ledSimpleAssistanceColor'],
            ledTipAssistanceColor: user['ledTipAssistanceColor'],
            ledFingerAssistanceColor: user['ledFingerAssistanceColor'],
            ledOkColor: user['ledOkColor'],
            ledNokColor: user['ledNokColor'],
          ),
        );
      },
    );
    return users;
  }

  static Future<List<Data>> getUserData(int userid) async {
    final db = await SqlHelper.database();
    List<Data> _data = [];
    final dataFromDb = await db.query(
      'data',
      where: 'userid = ?',
      whereArgs: [userid],
    );
    dataFromDb.forEach(
      (data) {
        _data.add(
          Data(
            id: data['id'],
            userid: data['userid'],
            username: data['username'],
            description: data['description'],
            pencilname: data['pencilname'],
            measurement: data['measurement'],
            timestamp: data['timestamp'],
          ),
        );
      },
    );
    return _data;
  }

  static Future<List<Data>> getData() async {
    final db = await SqlHelper.database();
    List<Data> _data = [];
    final dataFromDb = await db.query('data');
    dataFromDb.forEach(
      (data) {
        _data.add(
          Data(
            id: data['id'],
            userid: data['userid'],
            username: data['username'],
            description: data['description'],
            pencilname: data['pencilname'],
            measurement: data['measurement'],
            timestamp: data['timestamp'],
          ),
        );
      },
    );
    return _data;
  }

  static Future<void> deleteUser(int id) async {
    final db = await SqlHelper.database();
    print('Delete user with id $id');
    await db.delete(
      'data',
      where: 'userid = ?',
      whereArgs: [id],
    );
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteData(int userid) async {
    final db = await SqlHelper.database();
    print('Delete data with userid $userid');
    await db.delete(
      'data',
      where: 'userid = ?',
      whereArgs: [userid],
    );
  }

  static Future<void> deleteDataWhereId(int id) async {
    final db = await SqlHelper.database();
    print('Delete data with id $id');
    await db.delete(
      'data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
