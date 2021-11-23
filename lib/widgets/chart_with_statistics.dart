import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/display_chart.dart';
import '../providers/users_provider.dart';
import '../screens/data_selection_screen.dart';
// import '../models/text_styles.dart';
import '../models/data.dart';
import '../helpers/sql_helper.dart';

class ChartWithStatistics extends StatefulWidget {
  final int chartMode;
  final int userIndex;

  ChartWithStatistics(this.chartMode, [this.userIndex]);
  @override
  _ChartWithStatisticsState createState() => _ChartWithStatisticsState();
}

class _ChartWithStatisticsState extends State<ChartWithStatistics> {
  Data _data;
  List<Map<String, int>> _measurement;
  Map<String, int> _statistics;
  bool _expanded = true;

  void _parseData(Data data) {
    setState(
      () {
        _data = data;
        _measurement = _parseMeasurement(_data.measurement);
        _statistics = _calculateStatistics(_measurement);
      },
    );
  }

  void _getDataFromDatabase() async {
    await SqlHelper.getData().then(
      (data) {
        if (data.isNotEmpty) {
          if (widget.chartMode != 2)
            _parseData(data.last);
          else
            _parseData(data[widget.userIndex]);
        }
      },
    );
  }

  Map<String, int> _calculateStatistics(List<Map<String, int>> measurements) {
    List<int> tipSensorValues = [0];
    List<int> fingerSensorValues = [0];
    List<int> angleValues = [0];
    List<int> speedValues = [0];
    measurements.forEach(
      (measurement) {
        angleValues.add(measurement['angle']);
        speedValues.add(measurement['speed']);
        if (measurement['tipSensorValue'] > 5) {
          tipSensorValues.add(measurement['tipSensorValue']);
        }
        if (measurement['fingerSensorValue'] > 5) {
          fingerSensorValues.add(measurement['fingerSensorValue']);
        }
      },
    );
    tipSensorValues.sort((a, b) => a.compareTo(b));
    fingerSensorValues.sort((a, b) => a.compareTo(b));
    return {
      'timestamp':
          ((measurements.last['timestamp'] - measurements.first['timestamp']) /
                  10)
              .round(),
      'tipSensorMax': tipSensorValues.last,
      'tipSensorAverage':
          (tipSensorValues.reduce((value, element) => value + element) /
                  tipSensorValues.length)
              .round(),
      'tipSensorMedian': tipSensorValues[tipSensorValues.length ~/ 2],
      'fingerSensorMax': fingerSensorValues.last,
      'fingerSensorAverage':
          (fingerSensorValues.reduce((value, element) => value + element) /
                  fingerSensorValues.length)
              .round(),
      'fingerSensorMedian': fingerSensorValues[fingerSensorValues.length ~/ 2],
      'angleAverage': (angleValues.reduce((value, element) => value + element) /
              angleValues.length)
          .round(),
      'speedAverage': (speedValues.reduce((value, element) => value + element) /
              speedValues.length)
          .round(),
      'tipAndFingerSum':
          ((tipSensorValues.reduce((value, element) => value + element) +
                      fingerSensorValues
                          .reduce((value, element) => value + element)) /
                  1000)
              .round(),
    };
  }

  List<Map<String, int>> _parseMeasurement(String measurements) {
    List<Map<String, int>> converted = [];
    measurements.split('_').forEach(
      (measurement) {
        var splitedData = measurement.split(',');
        // print(splitedData);
        converted.add(
          {
            'timestamp': int.parse(splitedData[0]),
            'tipSensorValue': int.parse(splitedData[1]),
            'tipSensorUpperRange': int.parse(splitedData[2]),
            'tipSensorLowerRange': int.parse(splitedData[3]),
            'fingerSensorValue': int.parse(splitedData[4]),
            'fingerSensorUpperRange': int.parse(splitedData[5]),
            'fingerSensorLowerRange': int.parse(splitedData[6]),
            'angle': int.parse(splitedData[7]),
            'speed': int.parse(splitedData[8]),
          },
        );
      },
    );
    // print(converted);
    return converted;
  }

  @override
  void initState() {
    //SqlHelper.deleteDb('sensogrip');
    print('init chart with statistics');
    _getDataFromDatabase();
    super.initState();
  }

  Widget _buildDataStat(String title, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey),
            overflow: TextOverflow.fade,
          ),
        ),
        Text(
          data,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 22,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton(size) {
    return Container(
      width: 50,
      height: size,
      child: Card(
          color: Colors.grey.shade200,
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: IconButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon:
                  Icon(_expanded ? Icons.chevron_right : Icons.chevron_left))),
    );
  }

  Widget _buildSelectMeasButton() {
    return IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataSelectionScreen(_data),
          ),
        ).then((data) {
          if (data != null) {
            print('selected data from widget ${data.id}');
            // print(data.measurement);
            _parseData(data);
          }
        });
      },
      icon: Icon(Icons.search),
      iconSize: 30,
    );
  }

  Widget _buildStatisticsCard(users, size) {
    return Container(
      width: 380,
      // height: widget.isSmall ? 370 : 730,
      child: Card(
        margin: EdgeInsets.only(top: 5, bottom: 5, left: 1, right: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(users.where((user) => user.id == _data.userid)).first.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        '${_data.timestamp}',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          // color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.chartMode != 2) _buildSelectMeasButton(),
                SizedBox(
                  width: 25,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              height: size - 150,
              child: ListView(
                children: [
                  _buildDataStat(
                      AppLocalizations.of(context).protocol, _data.description),
                  _buildDataStat(AppLocalizations.of(context).pencilName,
                      _data.pencilname),
                  _buildDataStat(AppLocalizations.of(context).maxTipPressure,
                      _statistics['tipSensorMax'].toString()),
                  _buildDataStat(
                      AppLocalizations.of(context).averageTipPressure,
                      _statistics['tipSensorAverage'].toString()),
                  _buildDataStat(AppLocalizations.of(context).tipPressureMedian,
                      _statistics['tipSensorMedian'].toString()),
                  _buildDataStat(AppLocalizations.of(context).maxFingerPressure,
                      _statistics['fingerSensorMax'].toString()),
                  _buildDataStat(
                      AppLocalizations.of(context).averageFingerPressure,
                      _statistics['fingerSensorAverage'].toString()),
                  _buildDataStat(
                      AppLocalizations.of(context).fingerPressureMedian,
                      _statistics['fingerSensorMedian'].toString()),
                  _buildDataStat(AppLocalizations.of(context).averageAngle,
                      _statistics['angleAverage'].toString()),
                  _buildDataStat(AppLocalizations.of(context).averageSpeed,
                      _statistics['speedAverage'].toString()),
                  _buildDataStat(AppLocalizations.of(context).sumOfPressures,
                      _statistics['tipAndFingerSum'].toString()),
                  _buildDataStat(AppLocalizations.of(context).duration,
                      _statistics['timestamp'].toString()),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(size, users) {
    return Container(
      // height: widget.isSmall ? 370 : 730,
      height: size,
      child: Row(
        children: [
          Expanded(child: DisplayChart(_measurement)),
          if (_expanded) _buildStatisticsCard(users, size),
          _buildExpandButton(size),
        ],
      ),
    );
  }

  Widget _chartManager() {
    final size = MediaQuery.of(context).size;
    final users = Provider.of<UsersProvider>(context, listen: false).users;

    switch (widget.chartMode) {
      case 0:
        {
          double chartSize = size.height - 65;
          return _buildChart(chartSize, users);
        }
        break;
      case 1:
        {
          double chartSize = (size.height / 2) - 30;
          return _buildChart(chartSize, users);
        }
        break;
      default:
        {
          double chartSize = (size.height / 2.3) - 30;
          return _buildChart(chartSize, users);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _data == null ? Container() : _chartManager();
  }
}
