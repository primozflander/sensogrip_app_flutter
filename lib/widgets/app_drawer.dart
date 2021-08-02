import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/users_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/info_screen.dart';
import '../screens/profiles_screen.dart';
import '../screens/data_and_stats_screen.dart';
import '../screens/help_screen.dart';

class AppDrawer extends StatelessWidget {
  final isLocked;
  final Function onWillPop;
  AppDrawer(this.isLocked, this.onWillPop);

  @override
  Widget build(BuildContext context) {
    Widget buildListTile(String title, IconData icon, Function tapHandler) {
      return ListTile(
        leading: Icon(
          icon,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onTap: tapHandler,
      );
    }

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Consumer<UsersProvider>(
              builder: (ctx, user, _) => (user.selectedUser == null)
                  ? Text(AppLocalizations.of(context).hello + '!')
                  : Text(AppLocalizations.of(context).hello +
                      ', ${user.selectedUser.name}!'),
            ),
            automaticallyImplyLeading: false,
          ),
          SizedBox(
            height: 20,
          ),
          buildListTile(
            AppLocalizations.of(context).profiles,
            Icons.account_circle,
            () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pushNamed(ProfilesScreen.routeName);
            },
          ),
          if (isLocked == false)
            buildListTile(
              AppLocalizations.of(context).dataAndStats,
              Icons.timeline,
              () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pushNamed(DataAndStatsScreen.routeName);
              },
            ),
          if (isLocked == false)
            buildListTile(
              AppLocalizations.of(context).settings,
              Icons.settings,
              () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
            ),
          buildListTile(
            AppLocalizations.of(context).pencilInfo,
            Icons.info_outline,
            () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pushNamed(InfoScreen.routeName);
            },
          ),
          buildListTile(
            AppLocalizations.of(context).help,
            Icons.help,
            () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pushNamed(HelpScreen.routeName);
            },
          ),
          Expanded(child: Container()),
          ListTile(
            tileColor: Colors.black87,
            leading: Icon(
              Icons.bluetooth_disabled,
              size: 26,
              color: Colors.white,
            ),
            title: Text(
              AppLocalizations.of(context).disconnect,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            onTap: onWillPop,
          ),
        ],
      ),
    );
  }
}
