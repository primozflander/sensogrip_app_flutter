import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/data.dart';

class FirebaseCloudHelper {
  static Future<void> transferDataToCloud(String user, Data data) async {
    final url = 'https://sensogrip-default-rtdb.firebaseio.com/data/$user.json';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'id': data.id,
            'userid': data.userid,
            'description': data.description,
            'measurement': data.measurement,
            'timestamp': data.timestamp,
          }));
      print('response from firebase: ${json.decode(response.body)}');
    } catch (error) {
      print(error);
      throw error;
    }
  }

  static Future<void> transferDataListToCloud(
      String user, List<Data> data) async {
    await deleteCloudData(user);
    data.forEach((element) {
      transferDataToCloud(user, element);
    });
  }

  static Future<void> deleteCloudData(String user) async {
    final url = 'https://sensogrip-default-rtdb.firebaseio.com/data/$user.json';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode >= 400) {
        print('Could not delete data');
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
