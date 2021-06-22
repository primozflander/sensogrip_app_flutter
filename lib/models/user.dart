import 'package:flutter/foundation.dart';

class User {
  final int id;
  String name;
  String description;
  int tipSensorUpperRange;
  int tipSensorLowerRange;
  int fingerSensorUpperRange;
  int fingerSensorLowerRange;
  int isPositiveFeedback;
  int feedbackType;
  int isAIon;
  int isAngleCorrected;
  //int _tipPressureReleaseDelay;
  //int _ledTurnOnSpeed;
  int ledSimpleAssistanceColor;
  int ledTipAssistanceColor;
  int ledFingerAssistanceColor;
  int ledOkColor;
  int ledNokColor;

  User({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.tipSensorUpperRange,
    @required this.tipSensorLowerRange,
    @required this.fingerSensorUpperRange,
    @required this.fingerSensorLowerRange,
    @required this.isPositiveFeedback,
    @required this.feedbackType,
    @required this.isAIon,
    @required this.isAngleCorrected,
    @required this.ledSimpleAssistanceColor,
    @required this.ledTipAssistanceColor,
    @required this.ledFingerAssistanceColor,
    @required this.ledOkColor,
    @required this.ledNokColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'tipSensorUpperRange': tipSensorUpperRange,
      'tipSensorLowerRange': tipSensorLowerRange,
      'fingerSensorUpperRange': fingerSensorUpperRange,
      'fingerSensorLowerRange': fingerSensorLowerRange,
      'isPositiveFeedback': isPositiveFeedback,
      'feedbackType': feedbackType,
      'isAIon': isAIon,
      'isAngleCorrected': isAngleCorrected,
      'ledSimpleAssistanceColor': ledSimpleAssistanceColor,
      'ledTipAssistanceColor': ledTipAssistanceColor,
      'ledFingerAssistanceColor': ledFingerAssistanceColor,
      'ledOkColor': ledOkColor,
      'ledNokColor': ledNokColor,
    };
  }
}
