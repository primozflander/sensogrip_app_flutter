import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddUser extends StatefulWidget {
  final Function addUser;

  AddUser(this.addUser);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _userNameController = TextEditingController();

  void _submitData() {
    if (_userNameController.text.isEmpty) {
      return;
    }
    final enteredName = _userNameController.text;
    if (enteredName.isEmpty) {
      return;
    }
    widget.addUser(enteredName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 150,
          ),
          Container(
            width: 400,
            child: TextField(
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).enterName),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'Quicksand',
              ),
              controller: _userNameController,
              onSubmitted: (_) => _submitData(),
            ),
          ),
          Container(
            // width: 150,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.person_add,
                size: 30,
              ),
              label: Text(
                AppLocalizations.of(context).addUser,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).accentColor,
                //onPrimary: Colors.white,
              ),
              onPressed: () => _submitData(),
            ),
          ),
        ],
      ),
    );
  }
}
