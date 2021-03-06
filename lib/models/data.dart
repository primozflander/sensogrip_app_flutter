import 'package:flutter/foundation.dart';

class Data {
  final int id;
  final int userid;
  String username;
  String description;
  String pencilname;
  String measurement;
  String timestamp;
  String videofile;

  Data({
    @required this.id,
    @required this.userid,
    @required this.username,
    @required this.description,
    @required this.pencilname,
    @required this.measurement,
    @required this.timestamp,
    @required this.videofile,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userid,
      'username': username,
      'description': description,
      'pencilname': pencilname,
      'measurement': measurement,
      'timestamp': timestamp,
      'videofile': videofile,
    };
  }
}
