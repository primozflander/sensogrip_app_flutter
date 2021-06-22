import 'package:flutter/material.dart';

import '../models/user.dart';
import '../helpers/functions.dart';
import '../helpers/sql_helper.dart';

class UsersProvider with ChangeNotifier {
  User _selectedUser = User(
    id: null,
    name: 'null',
    description: 'default',
    tipSensorUpperRange: 170,
    tipSensorLowerRange: 30,
    fingerSensorUpperRange: 170,
    fingerSensorLowerRange: 30,
    isPositiveFeedback: 1,
    feedbackType: 4,
    isAIon: 0,
    isAngleCorrected: 1,
    ledSimpleAssistanceColor: 240,
    ledTipAssistanceColor: 180,
    ledFingerAssistanceColor: 300,
    ledOkColor: 120,
    ledNokColor: 0,
  );

  List<User> _users = [];

  List<User> get users {
    return [..._users];
  }

  User get selectedUser {
    return _selectedUser;
  }

  List<int> get userConfiguration {
    List configurationState = Functions.convertIntToBytes(
            _selectedUser.tipSensorUpperRange) +
        Functions.convertIntToBytes(_selectedUser.tipSensorLowerRange) +
        Functions.convertIntToBytes(_selectedUser.fingerSensorUpperRange) +
        Functions.convertIntToBytes(_selectedUser.fingerSensorLowerRange) +
        Functions.convertIntToBytes(_selectedUser.isPositiveFeedback) +
        Functions.convertIntToBytes(_selectedUser.feedbackType) +
        Functions.convertIntToBytes(_selectedUser.isAIon) +
        Functions.convertIntToBytes(_selectedUser.isAngleCorrected) +
        Functions.convertIntToBytes(80) +
        Functions.convertIntToBytes(8) +
        Functions.convertIntToBytes(_selectedUser.ledSimpleAssistanceColor) +
        Functions.convertIntToBytes(_selectedUser.ledTipAssistanceColor) +
        Functions.convertIntToBytes(_selectedUser.ledFingerAssistanceColor) +
        Functions.convertIntToBytes(_selectedUser.ledOkColor) +
        Functions.convertIntToBytes(_selectedUser.ledNokColor);
    return configurationState;
  }

  void updateUserConfiguration(List<int> configuration) {
    _selectedUser.tipSensorUpperRange = configuration[0];
    _selectedUser.tipSensorLowerRange = configuration[1];
    _selectedUser.fingerSensorUpperRange = configuration[2];
    _selectedUser.fingerSensorLowerRange = configuration[3];
    _selectedUser.isPositiveFeedback = configuration[4];
    _selectedUser.feedbackType = configuration[5];
    _selectedUser.isAIon = configuration[6];
    _selectedUser.isAngleCorrected = configuration[7];
    _selectedUser.ledSimpleAssistanceColor = configuration[8];
    _selectedUser.ledTipAssistanceColor = configuration[9];
    _selectedUser.ledFingerAssistanceColor = configuration[10];
    _selectedUser.ledOkColor = configuration[11];
    _selectedUser.ledNokColor = configuration[12];
    SqlHelper.updateUser(_selectedUser);
  }

  void setSelectedUser(User user) {
    _selectedUser = user;
  }

  void addUser(User user) {
    _users.add(user);
    print('User added to provider');
    notifyListeners();
  }

  void setUsers(List<User> users) {
    _users = users;
    print('Users updated in provider');
    notifyListeners();
  }
}
