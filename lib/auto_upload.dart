// import 'dart:io';
// import 'package:Photos/dashboard/widgets/upload_icon.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path/path.dart' as p;
//
// Future<List<File>> getWindowsFiles(DateTime lastBackupTime) async {
//   final userProfile = Platform.environment['USERPROFILE'];
//   if (userProfile == null) return [];
//   final picturesPath = p.join(userProfile, 'Pictures');
//   // final picturesPath = p.join(userProfile, 'Pictures/Screenshots');
//   final directory = Directory(picturesPath);
//   if (!await directory.exists()) return [];
//   final files = directory
//       .listSync()
//       .whereType<File>()
//       .where((file) {final ext = p.extension(file.path).toLowerCase();
//         return (ext == '.jpg' || ext == '.png' || ext == '.jpeg') && file.lastModifiedSync().isAfter(lastBackupTime);
//       }).toList();
//   return files;
// }
//
// Future<List<File>> getAndroidFiles(DateTime lastBackupTime) async {
//   final directory = Directory('/storage/emulated/0/DCIM/Pictures');
//   if (!await directory.exists()) return [];
//   final files = directory
//       .listSync()
//       .where((f) => f is File && (f.path.endsWith('.jpg') || f.path.endsWith('.png') || f.path.endsWith('.jpeg')) && f.lastModifiedSync().isAfter(lastBackupTime))
//       .cast<File>()
//       .toList();
//   return files;
// }
//
//
//
// Future<void> uploadCameraFiles(BuildContext? context) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   DateTime lastBackupTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastBackupTime') ?? 0);
//   print("Last Backup Time: $lastBackupTime");
//   List<File> files=[];
//   if(Platform.isAndroid){
//     files = await getAndroidFiles(lastBackupTime);
//   }else if(Platform.isWindows){
//     files = await getWindowsFiles(lastBackupTime);
//   }
//   if(files.isNotEmpty){
//     await handleMultipleFileUpload(files, context!, saveLastBackupTime: true);
//   }
// }