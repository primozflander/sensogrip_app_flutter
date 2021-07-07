import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/gen/flutterblue.pbjson.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:screen_recorder_flutter/screen_recorder_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:sensogrip_app/screens/connect_to_device_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../widgets/realtime_chart.dart';
import '../widgets/display_data_and_stats.dart';
import '../widgets/app_drawer.dart';
import '../widgets/display_locked.dart';
import '../models/data.dart';
import './start_screen.dart';
import '../models/text_styles.dart';
import '../helpers/functions.dart';
import '../helpers/sql_helper.dart';
import '../providers/ble_provider.dart';
import '../providers/users_provider.dart';

enum ViewOptions {
  ShowChart,
  ShowChartAndCamera,
}

class ChartScreen extends StatefulWidget {
  static const routeName = '/chart_screen';

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool _isRecording = false;
  bool _isCameraOn = false;
  bool _isLocked = true;
  bool _isCameraReady = false;
  CameraController _controller;
  List<String> _currentMeasurements = [];
  StreamSubscription<BluetoothDeviceState> bleConnectionStateSubscription;

  void _checkIfLocked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLocked = prefs.getBool('isLocked');
    if (_isLocked == null) {
      _isLocked = true;
    }
    setState(() {});
    print('lock status: $_isLocked');
  }

  void _unlock() async {
    setState(() {
      _isLocked = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLocked', false);
  }

  void _saveData() async {
    if (_isRecording == false) {
      _currentMeasurements = [];
      _isRecording = true;
      if (_isCameraOn) {
        ScreenRecorderFlutter.startScreenRecord;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(days: 1),
          content: Text(AppLocalizations.of(context).recording),
          backgroundColor: Colors.black87,
        ),
      );
    } else {
      _isRecording = false;
      if (_isCameraOn) {
        ScreenRecorderFlutter.stopScreenRecord;
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      await Functions.saveMeasurementDialog(context).then(
        (measurementDescription) {
          print('value from drop down $measurementDescription');
          if (measurementDescription != null) {
            String pencilName = Provider.of<BleProvider>(context, listen: false)
                .bleDevice
                .name
                .substring(9);
            _saveMeasurementToDb(
                _currentMeasurements, measurementDescription, pencilName);
            _saveMeasurementToFile(
                _currentMeasurements, measurementDescription, pencilName);
          }
        },
      );
    }
  }

  void _addMeasurementPoint(Map<String, dynamic> data) {
    _currentMeasurements.add(
        '${data['timestamp']},${data['tipSensorValue']},${data['tipSensorUpperRange']},${data['tipSensorLowerRange']},${data['fingerSensorValue']},${data['fingerSensorUpperRange']},${data['fingerSensorLowerRange']},${data['angle']},${data['speed']},${data['accX']},${data['accY']},${data['accZ']},${data['gyroX']},${data['gyroY']},${data['gyroZ']}');
  }

  void _saveMeasurementToDb(
      List<String> data, String description, String pencilName) {
    final user =
        Provider.of<UsersProvider>(context, listen: false).selectedUser;
    Data dbData = Data(
      id: null,
      userid: user.id,
      username: user.name,
      description: description,
      pencilname: pencilName,
      measurement: data.join('_'),
      timestamp: DateFormat('dd.MM.yyyy kk:mm:ss').format(
        DateTime.now(),
      ),
    );
    SqlHelper.insertData(dbData.toMap());
  }

  void _saveMeasurementToFile(
      List<String> data, String description, String pencilName) async {
    String fileHeader =
        'timestamp,tipPressure,tipUpperRange,tipLowerRange,fingerPressure,fingerUpperRange,fingerLowerRange,angle,writtingSpeed,accX,accY,accZ,gyroX,gyroY,gyroZ';
    data.insert(0, fileHeader);
    final userName =
        Provider.of<UsersProvider>(context, listen: false).selectedUser.name;
    String formattedDate = DateFormat('dd.MM.yyyy_kk.mm.ss').format(
      DateTime.now(),
    );
    await getExternalStorageDirectory().then(
      (directory) {
        File file = File(
            '${directory.path}/${description}_${pencilName}_${userName}_$formattedDate.txt');
        file.writeAsString(data.join('\n'), mode: FileMode.write);
      },
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              AppLocalizations.of(context).disconnectDevice,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            content: Text(AppLocalizations.of(context).disconnectDeviceQ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).no)),
              TextButton(
                  onPressed: () {
                    final device =
                        Provider.of<BleProvider>(context, listen: false)
                            .bleDevice;
                    Navigator.of(context).pop(true);
                    Navigator.of(context)
                        .pushReplacementNamed(StartScreen.routeName);
                    device.disconnect();
                  },
                  child: Text(AppLocalizations.of(context).yes)),
            ],
          ) ??
          false,
    );
  }

  void _initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    final orientation = await NativeDeviceOrientationCommunicator()
        .orientation(useSensor: true);
    DeviceOrientation camOrientaion;
    if (orientation == NativeDeviceOrientation.landscapeRight) {
      camOrientaion = DeviceOrientation.landscapeLeft;
    } else {
      camOrientaion = DeviceOrientation.landscapeRight;
    }
    print('orientation:-------------> $orientation $camOrientaion');
    _controller = CameraController(cameras.first, ResolutionPreset.max);
    _controller.lockCaptureOrientation(camOrientaion);
    _controller.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isCameraReady = true;
        });
      },
    );
  }

  Future<void> _initScreenRecorder() async {
    ScreenRecorderFlutter.init(onRecordingStarted: (started, msg) {
      print("Recording $started $msg");
    }, onRecodingCompleted: (path) {
      print("Recording completed $path");
    });
  }

  void _addBleConnectionListener() {
    var bleDevice = Provider.of<BleProvider>(context).bleDevice;
    bleConnectionStateSubscription = bleDevice.state.listen(
      (connectionState) async {
        print('Event: BLE conection state state: $connectionState');
        if (connectionState == BluetoothDeviceState.disconnected) {
          bleConnectionStateSubscription.cancel().then(
            (_) {
              bleDevice.disconnect();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => StartScreen()),
                  ModalRoute.withName(StartScreen.routeName));
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print('<chart screen init>');
    _initScreenRecorder();
    _checkIfLocked();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _addBleConnectionListener();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bleData = Provider.of<BleProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).chartView,
            style: TextStyles.appBarTextStyle,
          ),
          actions: [
            PopupMenuButton(
              onSelected: (ViewOptions selectedValue) {
                setState(
                  () {
                    if (selectedValue == ViewOptions.ShowChart) {
                      _isCameraOn = false;
                      // controller?.dispose();
                    } else {
                      _initCamera();
                      _isCameraOn = true;
                    }
                  },
                );
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    AppLocalizations.of(context).displayRealtimeChart,
                    // style: TextStyle(fontSize: 14),
                  ),
                  value: ViewOptions.ShowChart,
                ),
                PopupMenuItem(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    AppLocalizations.of(context).displayRealtimeChartAndVideo,
                    // style: TextStyle(fontSize: 14),
                  ),
                  value: ViewOptions.ShowChartAndCamera,
                ),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(_isLocked, _onWillPop),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _isLocked == false
                      ? RealtimeChart(
                          bleData.streamController,
                          _saveData,
                          _isCameraOn,
                        )
                      : DisplayLocked(_saveData, _isCameraOn, _unlock),
                  if (_isCameraOn &&
                      _isCameraReady &&
                      _controller.value.isInitialized)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 0, right: 10, bottom: 4),
                        height: size.height - 150,
                        // width: 590,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Transform.scale(
                            scale: 2,
                            child: Center(
                              child: CameraPreview(_controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            StreamBuilder<List<dynamic>>(
              stream: bleData.streamController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.active) {
                  var parsedData = Functions.parseStream(snapshot.data);
                  //print('Parsed data---------> $parsedData');
                  bleData.updateReceivedData(parsedData);
                  if (_isRecording) {
                    _addMeasurementPoint(parsedData);
                  }
                  return Container(
                    height: 140,
                    child: DisplayDataAndStats(
                      parsedData,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
