import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user.dart';
import '../models/text_styles.dart';
import '../helpers/functions.dart';
import '../providers/users_provider.dart';
import '../providers/ble_provider.dart';
import '../models/uuids.dart';
import '../screens/chart_screen.dart';

class UserItem extends StatelessWidget {
  final User user;
  final Function deleteUser;

  UserItem(this.user, this.deleteUser);

  void _selectUser(context) async {
    // Navigator.of(context).pop();
    // Navigator.of(context).pushNamed(ChartScreen.routeName);

    // if (Provider.of<UsersProvider>(context, listen: false).selectedUser.id ==
    //     null)
    //   Navigator.of(context).pushNamed(ChartScreen.routeName);
    // else
    Navigator.of(context).pushReplacementNamed(ChartScreen.routeName);
    Provider.of<UsersProvider>(context, listen: false).setSelectedUser(user);
    var configurationState =
        Provider.of<UsersProvider>(context, listen: false).userConfiguration;
    print('User selected ${user.id}');
    await Provider.of<BleProvider>(context, listen: false)
        .findByName(Uuid.configurationState)
        .write(configurationState);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildUserInfo(String title, String data) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            data,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 26,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      );
    }

    Widget _buildFeedbackInfo(int feedbackType) {
      String feedbackTypeString = '';
      switch (feedbackType) {
        case 0:
          feedbackTypeString = AppLocalizations.of(context).noFeedback;
          break;
        case 1:
          feedbackTypeString = AppLocalizations.of(context).bothSensorsInRange;
          break;
        case 2:
          feedbackTypeString = AppLocalizations.of(context).simpleFeedback;
          break;
        case 3:
          feedbackTypeString = AppLocalizations.of(context).advancedFeedback;
          break;
        case 4:
          feedbackTypeString =
              AppLocalizations.of(context).overpressureFeedback;
          break;
        case 4:
          feedbackTypeString = AppLocalizations.of(context).negativeFeedback;
          break;
      }
      return Container(
        // height: 100,
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          // shape: BoxShape.rectangle,

          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(AppLocalizations.of(context).feedbackType),
            SizedBox(
              height: 10,
            ),
            Text(
              feedbackTypeString,
              textAlign: TextAlign.center,
              // softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _selectUser(context),
      splashColor: Theme.of(context).primaryColor,
      //borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(5),
        elevation: 2,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipRRect(
              //borderRadius: BorderRadius.circular(15.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Container(
                height: 100,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: ListTile(
                  //selected: true,
                  leading: CircleAvatar(
                    backgroundColor: Functions.intToColor(user.ledOkColor),
                    radius: 30,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: FittedBox(
                          child: Text(
                        '${user.name[0]}',
                        style: TextStyles.avatarTextStyle,
                      )),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text('id: ${user.id}'),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                    ),
                    color: Theme.of(context).errorColor,
                    onPressed: () => deleteUser(user),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUserInfo(
                        AppLocalizations.of(context).tipSensorUpperRange,
                        user.tipSensorUpperRange.toString()),
                    _buildUserInfo(
                        AppLocalizations.of(context).tipSensorLowerRange,
                        user.tipSensorLowerRange.toString()),
                    _buildUserInfo(
                        AppLocalizations.of(context).fingerSensorUpperRange,
                        user.fingerSensorUpperRange.toString()),
                    _buildUserInfo(
                        AppLocalizations.of(context).fingerSensorLowerRange,
                        user.fingerSensorLowerRange.toString()),
                    // _buildUserInfo(
                    //     AppLocalizations.of(context).positiveFeedback,
                    //     (user.isPositiveFeedback == 1)
                    //         ? AppLocalizations.of(context).yes
                    //         : AppLocalizations.of(context).no),
                    _buildFeedbackInfo(user.feedbackType),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
