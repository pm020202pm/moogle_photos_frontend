import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import '../../Login/providers/auth_provider.dart';
import '../models/drive_file_model.dart';

class DriveFileProvider with ChangeNotifier {
  List<DriveFile> allFiles = [];
  bool isAllFilesLoading = false;
  String? nextPageToken;
  Set<String> selectedFileIds = {};
  double totalStorage = 1;
  double usedStorage=0;

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
    print('Setting files: ${files.length}');
    allFiles = files;
    notifyListeners();
  }

  void addFile(DriveFile file) {
    allFiles.insert(0, file);
    notifyListeners();
  }

  void addMoreFiles(List<DriveFile> files) {
    print('Adding more files: ${files.length}');
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
    print('Clearing selection');
    selectedFileIds.clear();
    notifyListeners();
  }

  void removeFile(String fileId) {
    print('Removing file: $fileId');
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
    nextPageToken = response.nextPageToken;
    isAllFilesLoading=false;
    notifyListeners();
  }

  List<DriveFile> get selectedFiles => allFiles.where((file) => selectedFileIds.contains(file.id)).toList();
}
