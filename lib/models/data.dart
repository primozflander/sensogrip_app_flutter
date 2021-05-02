import 'package:flutter/foundation.dart';

class Data {
  final int id;
  final int userid;
  String description;
  String measurement;
  String timestamp;

  Data({
    @required this.id,
    @required this.userid,
    @required this.description,
    @required this.measurement,
    @required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userid,
      'description': description,
      'measurement': measurement,
      'timestamp': timestamp,
    };
  }
}
