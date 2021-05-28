import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/ble_provider.dart';
import './profiles_screen.dart';
import './start_screen.dart';
import '../models/uuids.dart';
import '../models/text_styles.dart';

class ConnectToDeviceScreen extends StatefulWidget {
  static const routeName = '/connect_to_device_screen';
  @override
  _ConnectToDeviceScreenState createState() => _ConnectToDeviceScreenState();
}

class _ConnectToDeviceScreenState extends State<ConnectToDeviceScreen> {
  bool _isReady = false;
  Stream<List<int>> stream;
  StreamController<List<int>> _streamController =
      StreamController<List<int>>.broadcast();

  Future _connectToDevice(BluetoothDevice device) async {
    if (device == null) {
      _pop();
      return;
    }

    Timer(
      const Duration(seconds: 5),
      () {
        if (!_isReady) {
          _disconnectFromDevice(device);
          _pop();
        }
      },
    );

    await device.connect().then((_) => _discoverServices(device));
  }

  void _disconnectFromDevice(device) {
    if (device == null) {
      _pop();
      return;
    }
    device.disconnect();
  }

  Future _discoverServices(BluetoothDevice device) async {
    if (device == null) {
      _pop();
      return;
    }
    final bleCharProvider = Provider.of<BleProvider>(context, listen: false);
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == Uuid.sensogripService) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == Uuid.dataStream) {
            bleCharProvider.addBleChar(Uuid.dataStream, characteristic);
            await characteristic.setNotifyValue(!characteristic.isNotifying);
            await device.requestMtu(64).then(
              (value) {
                stream = characteristic.value;
                _streamController.addStream(stream);
                Provider.of<BleProvider>(context, listen: false)
                    .setStreamController(_streamController);
                _isReady = true;
              },
            );
          } else if (characteristic.uuid.toString() == Uuid.calibrate) {
            bleCharProvider.addBleChar(Uuid.calibrate, characteristic);
          } else if (characteristic.uuid.toString() ==
              Uuid.resetMinutesPassedInUse) {
            bleCharProvider.addBleChar(
                Uuid.resetMinutesPassedInUse, characteristic);
          } else if (characteristic.uuid.toString() ==
              Uuid.resetMinutesPassedInRange) {
            bleCharProvider.addBleChar(
                Uuid.resetMinutesPassedInRange, characteristic);
          } else if (characteristic.uuid.toString() ==
              Uuid.configurationState) {
            bleCharProvider.addBleChar(Uuid.configurationState, characteristic);
          }
        }
        // print(bleCharProvider.bleChars);
      }
    }
    if (_isReady) {
      Navigator.of(context).pushReplacementNamed(ProfilesScreen.routeName);
    } else
      _pop();
  }

  _pop() {
    Navigator.of(context).pushReplacementNamed(StartScreen.routeName);
  }

  @override
  void initState() {
    final device = Provider.of<BleProvider>(context, listen: false).bleDevice;
    _connectToDevice(device);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).connect,
          style: TextStyles.appBarTextStyle,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30),
            Text(
              AppLocalizations.of(context).loading,
              style: TextStyles.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
