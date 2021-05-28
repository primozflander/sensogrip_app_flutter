import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './display_sensor_stats.dart';
import './display_value.dart';

class DisplayDataAndStats extends StatelessWidget {
  final Map<String, dynamic> receivedData;

  DisplayDataAndStats(
    this.receivedData,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 5,
        ),
        DisplaySensorStats(AppLocalizations.of(context).tipSensor,
            receivedData['tipSensorValue']),
        DisplaySensorStats(AppLocalizations.of(context).fingerSensor,
            receivedData['fingerSensorValue']),
        DisplayValue(
          AppLocalizations.of(context).pencilAngle,
          receivedData['angle'],
          unit: AppLocalizations.of(context).deg,
        ),
        DisplayValue(
          AppLocalizations.of(context).writtingSpeed,
          (receivedData['speed'] < 15) ? 0 : receivedData['speed'],
        ),
        DisplayValue(
          AppLocalizations.of(context).batteryLevel,
          receivedData['batteryLevel'],
          unit: '%',
        ),
        SizedBox(
          width: 5,
        ),
      ],
    );
  }
}
