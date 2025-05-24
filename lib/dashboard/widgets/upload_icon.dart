import 'dart:io';
import 'package:Photos/Login/services/login_services.dart';
import 'package:Photos/services/files_services.dart';
import 'package:Photos/upload_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login/providers/auth_provider.dart';
import '../../home/models/drive_file_model.dart';
import '../../home/providers/drive_file_provider.dart';
class UploadIcon extends StatefulWidget {
  const UploadIcon({super.key});
  @override
  State<UploadIcon> createState() => _UploadIconState();
}

class _UploadIconState extends State<UploadIcon> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (BuildContext context, uploadProvider, Widget? child) {
        return IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: () async {
            print('uploading files');
            final result = await FilePicker.platform.pickFiles(allowMultiple: true);
            if (result != null && result.files.isNotEmpty) {
              List<File> selectedFiles = result.files.where((file) => file.path != null).map((file) => File(file.path!)).toList();
              uploadProvider.setFiles(selectedFiles);
              uploadProvider.setIsUploading(true);
              await handleMultipleFileUpload(selectedFiles, context);
              uploadProvider.setIsUploading(false);
            }
          },
        );
      },
    );
  }
}


Future<void> handleMultipleFileUpload(List<File> selectedFiles, BuildContext context, {bool saveLastBackupTime=false}) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
  final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
  List<String> accessTokens = authProvider.accessTokensList;
  for (int i = 0; i < selectedFiles.length; i++) {
    File file = selectedFiles[i];
    uploadProvider.setCurrentUploadIndex(i);
    final fileSize = await file.length();
    for(int i=0; i<4; i++){
      if(accessTokens[i].isNotEmpty){
        int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[i]);
        if(freeSpace!=null && freeSpace>fileSize+1048576000) {
          print("Uploading file to account ${i+1}");
          DriveFile? driveFile= await FileServices.uploadFile(file, accessTokens[i], authProvider.savedUser!.sharedFolderId);
          if(driveFile!=null) {
            fileProvider.addFile(driveFile);
            if(saveLastBackupTime){
              SharedPreferences prefs = await SharedPreferences.getInstance();
              DateTime backupTime = DateTime.now();
              await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
            }
          }
          break;
        }
      }
    }
  }

  uploadProvider.setCurrentUploadIndex(selectedFiles.length);
}


Future<void> handleAutoSingleFile(File file, BuildContext context, {bool saveLastBackupTime=false}) async {
  final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> refreshTokensList = prefs.getStringList('refreshTokensList')??['','','',''];
  List<String> accessTokens = ['','','',''];
  String folderId = prefs.getString('folderId') ?? '';
  final fileSize = await file.length();
  for(int i=0; i<4; i++){
      if(refreshTokensList[i].isNotEmpty){
        if(accessTokens[i].isEmpty){
          accessTokens[i] = await LoginServices.getAccessTokenFromBackend(refreshTokensList[i]);
        }
        if(accessTokens[i].isNotEmpty && folderId.isNotEmpty){
          int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[i]);
          if(freeSpace!=null && freeSpace>fileSize+1048576000) {
            DriveFile? driveFile= await FileServices.uploadFile(file, accessTokens[i], folderId);
            if(driveFile!=null) {
              fileProvider.addFile(driveFile);
              if(saveLastBackupTime){
                SharedPreferences prefs = await SharedPreferences.getInstance();
                DateTime backupTime = DateTime.now();
                await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
              }
            }
            break;
          }
        }
      }
    }
}

// Future<void> handleAutoSingleFile(List<File> selectedFiles, BuildContext context, {bool saveLastBackupTime=false}) async {
//   final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> refreshTokensList = prefs.getStringList('refreshTokensList')??['','','',''];
//   List<String> accessTokens = ['','','',''];
//   String folderId = prefs.getString('folderId') ?? '';
//
//   for (int i = 0; i < selectedFiles.length; i++) {
//     File file = selectedFiles[i];
//     final fileSize = await file.length();
//     for(int i=0; i<4; i++){
//       if(refreshTokensList[i].isNotEmpty){
//         if(accessTokens[i].isEmpty){
//           accessTokens[i] = await LoginServices.getAccessTokenFromBackend(refreshTokensList[i]);
//         }
//         if(accessTokens[i].isNotEmpty && folderId.isNotEmpty){
//           int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[i]);
//           if(freeSpace!=null && freeSpace>fileSize+1048576000) {
//             DriveFile? driveFile= await FileServices.uploadFile(file, accessTokens[i], folderId);
//             if(driveFile!=null) {
//               fileProvider.addFile(driveFile);
//               if(saveLastBackupTime){
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 DateTime backupTime = DateTime.now();
//                 await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
//               }
//             }
//             break;
//           }
//         }
//       }
//     }
//   }
// }