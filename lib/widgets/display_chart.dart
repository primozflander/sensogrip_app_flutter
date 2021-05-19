import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/adapter_android_mp.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/text_styles.dart';

class DisplayChart extends StatefulWidget {
  final List<Map<String, int>> dataToDisplay;

  DisplayChart(this.dataToDisplay);

  @override
  State<StatefulWidget> createState() {
    return DisplayChartState();
  }
}

class DisplayChartState extends State<DisplayChart> {
  LineChartController controller;

  static const int VISIBLE_COUNT = 6000;
  int _removalCounter = 0;
  int _drawTipSensor = 1;
  int _drawFingerSensor = 1;
  bool _drawAngle = false;
  bool _drawSpeed = false;

  void _initController() {
    controller = LineChartController(
      infoTextSize: 20,
      infoTextColor: Colors.grey,
      noDataText: AppLocalizations.of(context).noDataToDisplay,
      highLightPerTapEnabled: false,
      highlightPerDragEnabled: false,
      legendSettingFunction: (legend, controller) {
        legend
          ..shape = LegendForm.DEFAULT
          ..typeface = TypeFace(fontFamily: 'Quicksand')
          ..textSize = 20
          ..yOffset = 3.0
          ..xOffset = 0
          ..textColor = Colors.black;
      },
      xAxisSettingFunction: (xAxis, controller) {
        xAxis
          ..textColor = Colors.black
          ..drawGridLines = true
          ..enabled = true;
      },
      axisLeftSettingFunction: (axisLeft, controller) {
        axisLeft..enabled = false;
      },
      axisRightSettingFunction: (axisRight, controller) {
        axisRight..enabled = true;
      },
      drawBorders: true,
      borderColor: Colors.grey,
      borderStrokeWidth: 0.3,
      extraBottomOffset: 15,
      extraTopOffset: 0,
      drawGridBackground: false,
      backgroundColor: Colors.white,
      pinchZoomEnabled: false,
      minOffset: 15,
      scaleXEnabled: true,
      scaleYEnabled: true,
      dragXEnabled: true,
      dragYEnabled: true,
    );
    LineData data = controller?.data;
    if (data == null) {
      data = LineData();
      controller.data = data;
    }
  }

  void _addEntry(Map<String, int> dataEntry) {
    LineData data = controller.data;
    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      if (set == null) {
        set = _createTipSensorSet();
        data.addDataSet(set);
        data.addDataSet(_createFingerSensorSet());
        data.addDataSet(_createAngleSet());
        data.addDataSet(_createSpeedSet());
        data.addDataSet(_createTipMaxSet());
        data.addDataSet(_createTipMinSet());
        data.addDataSet(_createFingerMaxSet());
        data.addDataSet(_createFingerMinSet());
      }
      double x = (set.getEntryCount() + _removalCounter).toDouble() / 10;
      data.addEntry(
        Entry(
          x: x,
          y: _drawTipSensor != 0 ? dataEntry['tipSensorValue'].toDouble() : 0,
        ),
        0,
      );
      if (_drawFingerSensor > 0)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['fingerSensorValue'].toDouble(),
          ),
          1,
        );
      if (_drawAngle)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['angle'].toDouble(),
          ),
          2,
        );
      if (_drawSpeed)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['speed'].toDouble(),
          ),
          3,
        );
      if (_drawTipSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['tipSensorUpperRange'].toDouble(),
          ),
          4,
        );
      if (_drawTipSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['tipSensorLowerRange'].toDouble(),
          ),
          5,
        );
      if (_drawFingerSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['fingerSensorUpperRange'].toDouble(),
          ),
          6,
        );
      if (_drawFingerSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: dataEntry['fingerSensorLowerRange'].toDouble(),
          ),
          7,
        );
      if (set.getEntryCount() > VISIBLE_COUNT) {
        data.removeEntry2(_removalCounter.toDouble() / 10, 0);
        data.removeEntry2(_removalCounter.toDouble() / 10, 1);
        data.removeEntry2(_removalCounter.toDouble() / 10, 2);
        data.removeEntry2(_removalCounter.toDouble() / 10, 3);
        data.removeEntry2(_removalCounter.toDouble() / 10, 4);
        data.removeEntry2(_removalCounter.toDouble() / 10, 5);
        data.removeEntry2(_removalCounter.toDouble() / 10, 6);
        data.removeEntry2(_removalCounter.toDouble() / 10, 7);
        _removalCounter++;
      }
      data.notifyDataChanged();
      controller.setVisibleXRangeMaximum(300);
      controller.moveViewToX(data.getEntryCount().toDouble());
      controller.state?.setStateIfNotDispose();
    }
  }

  void _addEntries() {
    Future.delayed(Duration.zero).then((_) {
      _clearChart();
      widget.dataToDisplay.forEach(
        (entry) {
          _addEntry(entry);
        },
      );
      controller.animator.reset();
      controller.animator.animateY2(350, Easing.EaseInCubic);
    });
  }
  //   if (controller.state == null) {
  //     Timer(Duration(milliseconds: 500), _refresh);
  //   } else {
  //     _clearChart();
  //     widget.dataToDisplay.forEach(
  //       (entry) {
  //         _addEntry(entry);
  //       },
  //     );
  //     controller.animator.reset();
  //     controller.animator.animateY2(350, Easing.EaseInCubic);
  //   }
  // }

  void _clearChart() {
    controller.data?.clearValues();
    controller.state?.setStateIfNotDispose();
    //controller.viewPortHandler.fitScreen1();
  }

  Color _getColor(int selector) {
    switch (selector) {
      case 0:
        return Colors.grey;
        break;
      case 1:
        return Theme.of(context).accentColor;
        break;
      case 2:
        return Theme.of(context).primaryColor;
        break;
      default:
        return Colors.grey;
    }
  }

  // @override
  // void initState() {
  //   _initController();
  //   // _addEntries();
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    _initController();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _addEntries();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      ),
      margin: EdgeInsets.only(left: 10, top: 5, right: 0, bottom: 5),
      // elevation: 2,
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: _getColor(_drawTipSensor),
                  ),
                  child: Text(
                    AppLocalizations.of(context).tipSensorLetter,
                    style: TextStyles.avatarTextStyle,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _drawTipSensor += 1;
                        if (_drawTipSensor > 2) _drawTipSensor = 0;
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: _getColor(_drawFingerSensor),
                  ),
                  child: Text(
                    AppLocalizations.of(context).fingerSensorLetter,
                    style: TextStyles.avatarTextStyle,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _drawFingerSensor += 1;
                        if (_drawFingerSensor > 2) _drawFingerSensor = 0;
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: _drawAngle
                        ? Theme.of(context).accentColor
                        : Colors.grey,
                  ),
                  child: Text(
                    AppLocalizations.of(context).angleLetter,
                    style: TextStyles.avatarTextStyle,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _drawAngle = !_drawAngle;
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: _drawSpeed
                        ? Theme.of(context).accentColor
                        : Colors.grey,
                  ),
                  child: Text(
                    AppLocalizations.of(context).speedLetter,
                    style: TextStyles.avatarTextStyle,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _drawSpeed = !_drawSpeed;
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: LineChart(controller),
          ),
        ],
      ),
    );
  }

  LineDataSet _createTipSensorSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressure);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.blue[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerSensorSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).fingerPressure);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.red[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createAngleSet() {
    LineDataSet set = LineDataSet(null, AppLocalizations.of(context).angle);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.green[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createSpeedSet() {
    LineDataSet set = LineDataSet(null, AppLocalizations.of(context).speed);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.purple[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createTipMaxSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressureUpperRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.yellow[400]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createTipMinSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressureLowerRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.yellow[200]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerMaxSet() {
    LineDataSet set = LineDataSet(
        null, AppLocalizations.of(context).fingerPressureUpperRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.orange[300]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerMinSet() {
    LineDataSet set = LineDataSet(
        null, AppLocalizations.of(context).fingerPressureLowerRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.orange[200]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }
}
