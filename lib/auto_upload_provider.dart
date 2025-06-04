
import 'dart:io';
import 'package:Photos/Login/services/login_services.dart';
import 'package:Photos/auto_upload.dart';
import 'package:Photos/services/files_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/models/drive_file_model.dart';
import 'home/providers/drive_file_provider.dart';

class AutoUploadProvider with ChangeNotifier {
  bool isAutoUploading = false;
  FileUploadService fileUploadService = FileUploadService();
  late DriveFileProvider _driveFileProvider;

  void update(DriveFileProvider driveFileProvider) {
    _driveFileProvider = driveFileProvider;
  }
  Future<void> uploadCameraFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastBackupTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastBackupTime') ?? 0);
    List<String> refreshTokensList = prefs.getStringList('refreshTokensList')??['','','',''];
    List<String> accessTokens = ['','','',''];
    String folderId = prefs.getString('folderId') ?? '';
    print("Last Backup Time: $lastBackupTime");
    List<File> files=[];
    if(Platform.isAndroid || Platform.isWindows){
      files = Platform.isAndroid? await fileUploadService.getAndroidFiles(lastBackupTime): Platform.isWindows? await fileUploadService.getWindowsFiles(lastBackupTime) : [];
      if(files.isNotEmpty){
        isAutoUploading = true;
        notifyListeners();
        for(int i=0; i<files.length; i++){
          final fileSize = await files[i].length();
          for(int j=0; j<4; j++){
            if(refreshTokensList[j].isNotEmpty){
              if(accessTokens[j].isEmpty){
                accessTokens[j] = await LoginServices.getAccessTokenFromBackend(refreshTokensList[j]);
              }
              if(accessTokens[j].isNotEmpty && folderId.isNotEmpty){
                int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[j]);
                if(freeSpace!=null && freeSpace>fileSize+1048576000) {
                  DriveFile? driveFile= await FileServices.uploadFile(files[i], accessTokens[j], folderId);
                  if(driveFile!=null) {
                    _driveFileProvider.addFile(driveFile);
                    DateTime backupTime = DateTime.now();
                    await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
                  }
                  break;
                }
              }
            }
          }
        }
        isAutoUploading = false;
        notifyListeners();
      }
    } else if(Platform.isIOS){
      final assets = await fileUploadService.getIosCameraFiles(lastBackupTime);
      isAutoUploading = true;
      notifyListeners();
      for(int i=0; i<assets.length; i++){
        final file = await assets[i].file;
        if(file == null) continue;
        final fileSize = await file.length();
        for(int j=0; j<4; j++){
          if(refreshTokensList[j].isNotEmpty){
            if(accessTokens[j].isEmpty){
              accessTokens[j] = await LoginServices.getAccessTokenFromBackend(refreshTokensList[j]);
            }
            if(accessTokens[j].isNotEmpty && folderId.isNotEmpty){
              int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[j]);
              if(freeSpace!=null && freeSpace>fileSize+1048576000) {
                DriveFile? driveFile= await FileServices.uploadFile(file, accessTokens[j], folderId);
                if(driveFile!=null) {
                  _driveFileProvider.addFile(driveFile);
                  DateTime backupTime = DateTime.now();
                  await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
                }
                break;
              }
            }
          }
        }
      }
      isAutoUploading = false;
      notifyListeners();
    }
  }
}


