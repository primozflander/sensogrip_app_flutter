import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user.dart';
import '../models/text_styles.dart';
import '../widgets/add_user.dart';
import '../widgets/user_item.dart';
import '../helpers/sql_helper.dart';
import '../providers/users_provider.dart';

class ProfilesScreen extends StatefulWidget {
  static const routeName = '/profiles_screen';

  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  var _index = 0;
  List<User> _users = [];

  void _startAddNewUser(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (ctx) {
        return AddUser(_addNewUser);
      },
    );
  }

  void _addNewUser(String title) {
    final newUser = User(
      id: 9999,
      name: title,
      description: 'much wow',
      tipSensorUpperRange: 170,
      tipSensorLowerRange: 30,
      fingerSensorUpperRange: 180,
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
    SqlHelper.insertUser(newUser).then((_) => _getUsersFromDatabase());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).user +
            ' $title ' +
            AppLocalizations.of(context).created),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              AppLocalizations.of(context).deleteUser,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            content: Text(AppLocalizations.of(context).deleteProfileQ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).no)),
              TextButton(
                  onPressed: () {
                    SqlHelper.deleteUser(user.id)
                        .then((_) => _getUsersFromDatabase());
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalizations.of(context).yes)),
            ],
          ) ??
          false,
    );
  }

  void _getUsersFromDatabase() async {
    List<User> usersFromDb = await SqlHelper.getUsers();
    setState(() {
      Provider.of<UsersProvider>(context, listen: false).setUsers(usersFromDb);
      _users = usersFromDb;
    });
  }

  @override
  void initState() {
    //SqlHelper.deleteDb('sensogrip');
    print('Profiles screen init');
    _getUsersFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).profiles,
          style: TextStyles.appBarTextStyle,
        ),
      ),
      body: _users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                    child: Image.asset('assets/images/add_user.png'),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    AppLocalizations.of(context).noUsersYet,
                    style: TextStyles.textGrey,
                  ),
                ],
              ),
            )
          : Center(
              child: SizedBox(
                height: size.height - 230, // card height
                child: PageView.builder(
                  itemCount: _users.length,
                  controller: PageController(viewportFraction: 0.3),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (ctx, i) {
                    return Transform.scale(
                      scale: i == _index ? 1 : 0.8,
                      child: UserItem(
                        _users[i],
                        _deleteUser,
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewUser(context),
      ),
    );
  }
}
