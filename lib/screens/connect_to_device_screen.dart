import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sensogrip_app/widgets/ble_helpers.dart';

import '../providers/ble_provider.dart';
import './profiles_screen.dart';
import '../models/uuids.dart';
import '../models/text_styles.dart';

class ConnectToDeviceScreen extends StatefulWidget {
  static const routeName = '/connect_to_device_screen';
  @override
  _ConnectToDeviceScreenState createState() => _ConnectToDeviceScreenState();
}

class _ConnectToDeviceScreenState extends State<ConnectToDeviceScreen> {
  bool _isReady = false;
  bool _isLoading = false;
  Stream<List<int>> stream;
  StreamController<List<int>> _streamController =
      StreamController<List<int>>.broadcast();
  StreamSubscription<BluetoothDeviceState> bleConnectionStateSubscription;

  Future _connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false, timeout: Duration(seconds: 5));
    _addConnectionListener(device);
  }

  Future _discoverServices(BluetoothDevice device) async {
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
      Navigator.of(context).pushNamed(ProfilesScreen.routeName);
    } else
      device.disconnect();
  }

  void _addConnectionListener(device) {
    final bleCharProvider = Provider.of<BleProvider>(context, listen: false);
    bleConnectionStateSubscription = device.state.listen(
      (connectionState) async {
        print('Event: BLE conection state state: $connectionState');
        if (connectionState == BluetoothDeviceState.disconnected) {
          bleCharProvider.setIsConnected(false);
          await bleConnectionStateSubscription.cancel();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => ConnectToDeviceScreen()),
              ModalRoute.withName(ConnectToDeviceScreen.routeName));
          setState(() {
            _isLoading = false;
          });
        }
        if (connectionState == BluetoothDeviceState.connected) {
          bleCharProvider.setIsConnected(true);
          await _discoverServices(device);
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _selectDevice(BluetoothDevice device) {
    setState(() {
      _isLoading = true;
    });
    _connectToDevice(device);
  }

  @override
  void initState() {
    print('<connect to device screen init>');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
    } else {
      return FindDevicesScreen(_selectDevice);
    }
  }
}
