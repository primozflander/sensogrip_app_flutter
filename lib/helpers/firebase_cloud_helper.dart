import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

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

  static Future<bool> transferDataListToCloud(
      String user, List<Data> data) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return true;
    final response = await deleteCloudData(user);
    print('response from delete $response');
    if (response == true) return true;
    data.forEach((element) {
      transferDataToCloud(user, element);
    });
    return false;
  }

  static Future<bool> deleteCloudData(String user) async {
    final url = 'https://sensogrip-default-rtdb.firebaseio.com/data/$user.json';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode >= 400) {
        print('Could not delete data');
        return true;
      }
      return false;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
