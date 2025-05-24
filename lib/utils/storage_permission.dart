import 'package:permission_handler/permission_handler.dart';
Future<bool> requestPermissions() async {
  var manageStorage = await Permission.manageExternalStorage.status;
  if (!manageStorage.isGranted) {
    manageStorage = await Permission.manageExternalStorage.request();
  }
  return manageStorage.isGranted;
}