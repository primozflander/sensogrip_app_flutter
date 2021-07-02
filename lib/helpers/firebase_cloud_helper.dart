import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';

import '../models/data.dart';
import '../models/http_exception.dart';
import '../credentials/credentials.dart';

const String DATABASE_BASEPATH =
    'https://sensogripauth-default-rtdb.europe-west1.firebasedatabase.app/data/';

class FirebaseCloudHelper {
  static Future<String> login() async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Credentials.API_KEY}';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': Credentials.EMAIL,
            'password': Credentials.PASSWORD,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print(responseData['error']);
        throw HttpException(responseData['error']['message']);
      }
      return responseData['idToken'];
    } catch (error) {
      throw error;
    }
  }

  static Future<void> transferDataToCloud(
      String user, Data data, String authToken) async {
    final url = '$DATABASE_BASEPATH/$user.json?auth=$authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'id': data.id,
            'userid': data.userid,
            'username': data.username,
            'description': data.description,
            'pencilname': data.pencilname,
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
    DateTime timeStamp = DateTime.now();
    String formattedDate = DateFormat('yyyy-dd-MM-kk-mm-ss').format(timeStamp);
    print(formattedDate);
    print('$user$formattedDate');
    print('data: $data');
    user = user + '/$formattedDate';
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return true;
    var authToken = await login();
    // final response = await deleteCloudData(user, authToken);
    // if (response == true) return true;
    print('------------<hereeee');
    data.forEach((element) {
      transferDataToCloud(user, element, authToken);
    });
    return false;
  }

  static Future<bool> deleteCloudData(String user, String authToken) async {
    final url = '$DATABASE_BASEPATH$user.json?auth=$authToken';
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
