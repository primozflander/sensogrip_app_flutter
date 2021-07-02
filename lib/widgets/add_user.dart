import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/users_provider.dart';
import '../models/user.dart';

class AddUser extends StatefulWidget {
  final Function addUser;

  AddUser(this.addUser);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _form = GlobalKey<FormState>();

  void _submitData() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
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
            child: Form(
              key: _form,
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).enterName),
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.grey,
                  fontFamily: 'Quicksand',
                ),
                // controller: _userNameController,
                onChanged: (_) {
                  setState(() {});
                },
                onSaved: (value) => widget.addUser(value),
                validator: (value) {
                  List<User> existingUsers =
                      Provider.of<UsersProvider>(context, listen: false).users;
                  if (value.isEmpty || value.trim() == "") {
                    return AppLocalizations.of(context).provideValidNameF;
                  }
                  if (existingUsers
                      .where((user) => user.name == value.trim())
                      .isNotEmpty) {
                    return AppLocalizations.of(context).userExistsF;
                  }
                  if (value.trim().length > 20) {
                    return AppLocalizations.of(context).nameTooLongF;
                  }
                  return null;
                },
              ),
            ),
          ),
          Container(
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
                primary: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => _submitData(),
            ),
          ),
        ],
      ),
    );
  }
}
