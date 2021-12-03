import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _index = 0;
  List<User> _users = [];
  PageController _controller = PageController(viewportFraction: 0.3);

  void _startAddNewUser(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (ctx) {
        return AddUser(_addNewUser);
      },
    );
  }

  void _addNewUser(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLocked = prefs.getBool('isLocked');
    final newUser = User(
      id: null,
      name: title,
      description: 'much wow',
      tipSensorUpperRange: 170,
      tipSensorLowerRange: 30,
      fingerSensorUpperRange: 170,
      fingerSensorLowerRange: 30,
      isPositiveFeedback: 1,
      feedbackType: isLocked != false ? 0 : 4,
      isAIon: 0,
      isAngleCorrected: 1,
      ledSimpleAssistanceColor: 240,
      ledTipAssistanceColor: 180,
      ledFingerAssistanceColor: 300,
      ledOkColor: 120,
      ledNokColor: 0,
    );

    await SqlHelper.insertUser(newUser);
    await _getUsersFromDatabase();
    var userIndex = _users.indexWhere((user) => user.name == newUser.name);
    _controller.jumpToPage(userIndex);
    setState(() {
      _index = userIndex;
    });
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
                  onPressed: () async {
                    SqlHelper.deleteUser(user.id)
                        .then((_) => _getUsersFromDatabase());
                    Navigator.of(context).pop(true);
                    var userIndex = _users.indexWhere(
                        (userToDelete) => userToDelete.name == user.name);
                    _controller.jumpToPage(userIndex - 1);
                    setState(() {
                      _index = userIndex - 1;
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setInt('profilesScrollIndex', userIndex - 1);
                  },
                  child: Text(AppLocalizations.of(context).yes)),
            ],
          ) ??
          false,
    );
  }

  Future<void> _getUsersFromDatabase() async {
    List<User> usersFromDb = await SqlHelper.getUsers();
    setState(() {
      usersFromDb.sort((a, b) => a.name.compareTo(b.name));
      Provider.of<UsersProvider>(context, listen: false).setUsers(usersFromDb);
      _users = usersFromDb;
    });
  }

  void _setProfileFocus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var index = prefs.getInt('profilesScrollIndex');
    if (index != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpToPage(index);
        }
      });
      // _index = index;
    }
  }

  @override
  void initState() {
    // SqlHelper.deleteDb('sensogrip');
    print('<profiles screen init>');
    _getUsersFromDatabase();
    _setProfileFocus();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // _getProfileFocus(_index);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height - 200, // card height
                  child: PageView.builder(
                    itemCount: _users.length,
                    controller: _controller,
                    onPageChanged: (int index) async {
                      setState(() => _index = index);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setInt('profilesScrollIndex', index);
                    },
                    itemBuilder: (ctx, i) {
                      return Transform.scale(
                        scale: i == _index ? 1 : 0.8,
                        child: UserItem(
                          _users[i],
                          _deleteUser,
                          i == _index,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewUser(context),
      ),
    );
  }
}
