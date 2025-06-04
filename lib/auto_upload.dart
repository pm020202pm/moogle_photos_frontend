
import 'package:Photos/services/files_services.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/services/login_services.dart';
import 'home/models/drive_file_model.dart';
class FileUploadService{

  Future<void> backgroundUploadCameraFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastBackupTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastBackupTime') ?? 0);
    List<String> refreshTokensList = prefs.getStringList('refreshTokensList')??['','','',''];
    List<String> accessTokens = ['','','',''];
    String folderId = prefs.getString('folderId') ?? '';
    List<File> files=[];
    if(Platform.isAndroid){
      files = await getAndroidFiles(lastBackupTime);
      if(files.isNotEmpty){
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
                    DateTime backupTime = DateTime.now();
                    await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
                  }
                  break;
                }
              }
            }
          }
        }
      }
    } else if(Platform.isIOS){
      final assets = await getIosCameraFiles(lastBackupTime);
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
                  DateTime backupTime = DateTime.now();
                  await prefs.setInt('lastBackupTime', backupTime.millisecondsSinceEpoch);
                }
                break;
              }
            }
          }
        }
      }
    }
  }

  Future<List<File>> getWindowsFiles(DateTime lastBackupTime) async {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile == null) return [];
    // final picturesPath = p.join(userProfile, 'Pictures');
    final picturesPath = p.join(userProfile, 'Pictures/Screenshots');
    final directory = Directory(picturesPath);
    if (!await directory.exists()) return [];
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) {final ext = p.extension(file.path).toLowerCase();
    return (ext == '.jpg' || ext == '.png' || ext == '.jpeg') && file.lastModifiedSync().isAfter(lastBackupTime);
    }).toList();
    return files;
  }


  Future<List<File>> getAndroidFiles(DateTime lastBackupTime) async {
    final directory = Directory('/storage/emulated/0/DCIM/Pictures');
    if (!await directory.exists()) return [];
    final files = directory
        .listSync()
        .where((f) => f is File && (f.path.endsWith('.jpg') || f.path.endsWith('.png') || f.path.endsWith('.jpeg')) && f.lastModifiedSync().isAfter(lastBackupTime))
        .cast<File>()
        .toList();
    return files;
  }


  Future<List<AssetEntity>> getIosCameraFiles(DateTime lastBackupTime) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return [];
    final filterOptions = FilterOptionGroup(
      imageOption: const FilterOption(),
      createTimeCond: DateTimeCond(min: lastBackupTime, max: DateTime.now()),
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOptions,
    );
    if (albums.isEmpty) return [];
    final AssetPathEntity album = albums.firstWhere(
          (a) => a.name.toLowerCase().contains('camera') || a.name.toLowerCase().contains('recent'),
      orElse: () => albums.first,
    );


    // Then fetch assets from that filtered album
    final List<AssetEntity> assets = await album.getAssetListPaged(
      page: 0,
      size: 10,
    );
    return assets;
  }
}