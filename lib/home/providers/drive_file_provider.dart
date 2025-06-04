import 'dart:io';

import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login/providers/auth_provider.dart';
import '../models/drive_file_model.dart';

class DriveFileProvider with ChangeNotifier {
  List<DriveFile> allFiles = [];
  bool isAllFilesLoading = false;
  String? nextPageToken;
  Set<String> selectedFileIds = {};
  double totalStorage = 1;
  double usedStorage=0;
  bool isSyncing = false;

  late AuthProvider _authProvider;

  void update(AuthProvider auth) {
    _authProvider = auth;
  }

  Future<void> getStorage() async {
    List<String> accessTokens = _authProvider.accessTokensList;
    double freeSpaceFromApi = 0;
    double totalSpaceFromApi = 0;
    const double defaultTotalSpace = 15 * 1024 * 1024 * 1024;
    for(int i=0; i<4; i++){
      if(accessTokens[i].isNotEmpty){
        int? freeSpace = await FileServices.getDriveStorageQuota(accessTokens[i]);
        if(freeSpace!=null) {
          freeSpaceFromApi +=freeSpace;
          totalSpaceFromApi +=defaultTotalSpace;
        }
      }
    }
    if(totalSpaceFromApi==0){
      totalSpaceFromApi = 1;
    }
    totalStorage= totalSpaceFromApi/1024/1024/1024;
    usedStorage = totalStorage - freeSpaceFromApi/1024/1024/1024;
    notifyListeners();
  }
  void setFiles(List<DriveFile> files) {
    allFiles = files;
    notifyListeners();
  }

  void addFile(DriveFile file) {
    allFiles.insert(0, file);
    notifyListeners();
  }

  void addMoreFiles(List<DriveFile> files) {
    allFiles.addAll(files);
    notifyListeners();
  }

  void toggleSelection(String fileId) {
    if (selectedFileIds.contains(fileId)) {
      selectedFileIds.remove(fileId);
    } else {
      selectedFileIds.add(fileId);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedFileIds.clear();
    notifyListeners();
  }

  void removeFile(String fileId) {
    allFiles.removeWhere((file) => file.id == fileId);
    selectedFileIds.remove(fileId);
    notifyListeners();
  }

  Future<void> loadFilesFromDrive({bool isInitialLoad=false}) async {
    if (nextPageToken== null && !isInitialLoad) return;
    isAllFilesLoading=true;
    notifyListeners();
    String folderId = _authProvider.folderId;
    String refreshToken = _authProvider.refreshTokensList[0];
    if(refreshToken.isEmpty) {
      isAllFilesLoading=false;
      notifyListeners();
      return;
    }
    if (isInitialLoad) {
      allFiles.clear();
      nextPageToken = null;
    }
    final response = await FileServices.fetchDriveFiles(folderId: folderId, pageToken: nextPageToken, refreshToken: refreshToken);
    isInitialLoad? setFiles(response.files) : addMoreFiles(response.files);
    if(isInitialLoad){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastSyncTime', DateTime.now().toUtc().toIso8601String());
    }
    nextPageToken = response.nextPageToken;
    isAllFilesLoading=false;
    notifyListeners();
  }


  Future<void> syncFilesWithDrive() async {
    isSyncing = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSyncTime = prefs.getString('lastSyncTime');
    print('Last sync time: $lastSyncTime');
    String folderId = _authProvider.folderId;
    String refreshToken = _authProvider.refreshTokensList[0];
    if(refreshToken.isEmpty) {
      return;
    }
    final response = await FileServices.fetchDriveFiles(modifiedAfter: lastSyncTime,folderId: folderId, pageToken: null, refreshToken: refreshToken, pageSize: 50);
    List<DriveFile> filesToSync = response.files;
    filesToSync = filesToSync.where((file) => !allFiles.any((existingFile) => existingFile.id == file.id)).toList();
    allFiles.insertAll(0, filesToSync);
    prefs.setString('lastSyncTime', DateTime.now().toUtc().toIso8601String());
    isSyncing= false;
    notifyListeners();
  }




  List<DriveFile> get selectedFiles => allFiles.where((file) => selectedFileIds.contains(file.id)).toList();
}
