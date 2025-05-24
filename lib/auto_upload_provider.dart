
import 'dart:io';
import 'package:Photos/Login/services/login_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'dashboard/widgets/upload_icon.dart';

class AutoUploadProvider with ChangeNotifier {

  bool isAutoUploading = false;
  Future<void> uploadCameraFiles(BuildContext? context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastBackupTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastBackupTime') ?? 0);
    print("Last Backup Time: $lastBackupTime");
    List<File> files=[];
    if(Platform.isAndroid){
      files = await getAndroidFiles(lastBackupTime);
    }else if(Platform.isWindows){
      files = await getWindowsFiles(lastBackupTime);
    }else if(Platform.isIOS){
      successSnackMsg('on iOS', context!);
      final assets = await getIosCameraFilesAsFiles(lastBackupTime, context);
      final file = await assets[0].file;
      if(file == null) return;
      successSnackMsg('${file.path}', context);
      files = [file];
      // files = await Future.wait(assets.map((asset) async {
      //   final file = await asset.file;
      //   return file!;
      // }));
    }

    if(files.isNotEmpty){
      isAutoUploading = true;
      notifyListeners();
      await handleMultipleFileUpload(files, context!, saveLastBackupTime: true);
      isAutoUploading = false;
      notifyListeners();
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


  Future<List<AssetEntity>> getIosCameraFilesAsFiles(DateTime lastBackupTime, BuildContext context) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return [];

    successSnackMsg('Permission granted', context);
    // Define the filter here
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
    successSnackMsg('total ${albums.length} albums fetched', context);

    if (albums.isEmpty) return [];

    successSnackMsg('${albums[0].name}', context);
    final AssetPathEntity album = albums.firstWhere(
          (a) => a.name.toLowerCase().contains('camera') || a.name.toLowerCase().contains('recent'),
      orElse: () => albums.first,
    );


    // Then fetch assets from that filtered album
    final List<AssetEntity> assets = await album.getAssetListPaged(
      page: 0,
      size: 10,
    );
    successSnackMsg('total ${assets.length} assets fetched', context);
    return assets;
  }

}