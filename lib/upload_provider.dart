import 'dart:io';

import 'package:flutter/cupertino.dart';

class UploadProvider with ChangeNotifier {
  bool isUploading = false;
  List<File> files = [];
  int get totalFiles => files.length;
  int currentUploadIndex = 0;
  String get currentFileName => files.isNotEmpty ? files[currentUploadIndex].path.split('\\').last : '';

  void setFiles(List<File> newFiles) {
    files = newFiles;
    notifyListeners();
  }
  void setCurrentUploadIndex(int index) {
    currentUploadIndex = index;
    notifyListeners();
  }

  void setIsUploading(bool value) {
    print('isUploading: $value');
    isUploading = value;
    notifyListeners();
  }

}