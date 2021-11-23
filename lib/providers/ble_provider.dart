import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleProvider with ChangeNotifier {
  BluetoothDevice _device;
  bool _isConnected = false;
  Stream<List<dynamic>> _stream;
  StreamController _streamController;
  Map<String, dynamic> _receivedData = {};
  Map<String, BluetoothCharacteristic> _bleChars = {};

  Map<String, BluetoothCharacteristic> get bleChars {
    return _bleChars;
  }

  BluetoothCharacteristic findByName(String name) {
    return _bleChars[name];
  }

  void addBleChar(String name, BluetoothCharacteristic char) {
    _bleChars[name] = char;
    print('ble $name inserted');
    //notifyListeners();
  }

  void setBleDevice(BluetoothDevice device) {
    _device = device;
  }

  BluetoothDevice get bleDevice {
    return _device;
  }

  void setIsConnected(bool state) {
    _isConnected = state;
    //notifyListeners();
  }

  bool get isConnected {
    return _isConnected;
  }

  void setStream(Stream<List<dynamic>> stream) {
    _stream = stream;
    //notifyListeners();
  }

  Stream<List<dynamic>> get stream {
    return _stream;
  }

  void setStreamController(StreamController streamController) {
    _streamController = streamController;
    //notifyListeners();
  }

  StreamController get streamController {
    return _streamController;
  }

  Map<String, dynamic> get receivedData {
    return _receivedData;
  }

  int findReceivedDataByName(String name) {
    return _receivedData[name];
  }

  void updateReceivedData(Map<String, dynamic> data) {
    _receivedData = data;
    //print(_receivedData);
    //notifyListeners();
  }
}
