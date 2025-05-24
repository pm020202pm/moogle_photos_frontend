import 'dart:async';
import 'dart:io';
import 'package:Photos/auto_upload_provider.dart';
import 'package:Photos/dashboard/dashboard_provider.dart';
import 'package:Photos/splashscreen.dart';
import 'package:Photos/upload_provider.dart';
import 'package:Photos/utils/storage_permission.dart';
import 'package:Photos/utils/tray_handlers.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'Login/providers/auth_provider.dart';
import 'auto_upload.dart';
import 'home/providers/drive_file_provider.dart';

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  final bool granted = await requestPermissions();
  if (granted) {
    // AutoUploadProvider autoUploadProvider = AutoUploadProvider();
    // await autoUploadProvider.uploadCameraFiles(null);
    // await uploadCameraFiles(null);
  }
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb){
    if(Platform.isWindows || Platform.isLinux) {
      await windowManager.ensureInitialized();
      windowManager.setPreventClose(true);
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DriveFileProvider>(
          create: (_) => DriveFileProvider(),
          update: (_, authProvider, driveFileProvider) {
            driveFileProvider!.update(authProvider);
            return driveFileProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AutoUploadProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider())
      ],
      child: MyApp(),
    ));

  if(!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }
    if(Platform.isWindows || Platform.isLinux) {
      final iconPath = Platform.isWindows
          ? '${Directory.current.path}\\windows\\runner\\resources\\app_icon.ico'
          : 'assets/icons8-google-photos-32.png';

      await trayManager.setIcon(iconPath);
      await trayManager.setContextMenu(
          Menu(
              items: [
                MenuItem(label: 'Show App', key: 'show'),
                MenuItem(label: 'Exit', key: 'exit'),
              ]
          )
      );
      final trayHandler = MyTrayHandler();
      trayManager.addListener(trayHandler);
      windowManager.addListener(MyWindowHandler());
    }
  }

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  bool isLoggedIn = false;
  Timer? _autoUploadTimer;
  @override
  void initState() {
    super.initState();
    if(!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        initPlatformState();
      }
    }

    startAutoUploadTimer();
  }

  void startAutoUploadTimer() {
    _autoUploadTimer?.cancel();
    _autoUploadTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
      final autoUploadProvider = Provider.of<AutoUploadProvider>(context, listen: false);
      autoUploadProvider.uploadCameraFiles(context);
      // await uploadCameraFiles(context);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      var status = await BackgroundFetch.configure(BackgroundFetchConfig(
          minimumFetchInterval: 15,
          forceAlarmManager: false,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE
      ), _onBackgroundFetch, _onBackgroundFetchTimeout);
    } on Exception catch(e) {
      debugPrint("[BackgroundFetch] configure ERROR: $e");
    }
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    final bool granted = await requestPermissions();
    if (granted) {
      final autoUploadProvider = Provider.of<AutoUploadProvider>(context, listen: false);
      await autoUploadProvider.uploadCameraFiles(context);
      // await uploadCameraFiles(context);
    }
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    BackgroundFetch.finish(taskId);
  }

  @override
  void dispose() {
    _autoUploadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.blue,
      debugShowCheckedModeBanner: false,
      home: Splashscreen()
    );
  }
}

