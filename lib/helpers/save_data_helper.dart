
// import 'dart:io';

// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../models/data.dart';
// import '../helpers/sql_helper.dart';
// import '../providers/users_provider.dart';
  
//   void saveMeasurementToDb(List<String> data, String description) {
//     final id =
//         Provider.of<UsersProvider>(context, listen: false).selectedUser.id;
//     Data dbData = Data(
//       id: null,
//       userid: id,
//       description: description,
//       measurement: data.join('_'),
//       timestamp: DateFormat('dd.MM.yyyy kk:mm:ss').format(
//         DateTime.now(),
//       ),
//     );
//     SqlHelper.insertData(dbData.toMap());
//   }

//   void saveMeasurementToFile(List<String> data, String description) async {
//     String fileHeader =
//         'timestamp,tipSensorValue,fingerSensorValue,angle,speed,tipSensorUpperRange,tipSensorLowerRange,fingerSensorUpperRange,fingerSensorLowerRange';
//     data.insert(0, fileHeader);
//     final userName =
//         Provider.of<UsersProvider>(context, listen: false).selectedUser.name;
//     String formattedDate = DateFormat('dd.MM.yyyy_kk.mm.ss').format(
//       DateTime.now(),
//     );
//     await getExternalStorageDirectory().then(
//       (directory) {
//         File file = File(
//             '${directory.path}/${description}_${userName}_$formattedDate.txt');
//         file.writeAsString(data.join('\n'), mode: FileMode.write);
//       },
//     );
//   }