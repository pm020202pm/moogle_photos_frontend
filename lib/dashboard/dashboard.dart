import 'dart:async';

import 'package:Photos/dashboard/widgets/action_button_desktop.dart';
import 'package:Photos/dashboard/widgets/nav_button.dart';
import 'package:Photos/dashboard/widgets/sidebar.dart';
import 'package:Photos/dashboard/widgets/upload_status_dialog.dart';
import 'package:Photos/home/pages/photos_tab_desktop.dart';
import 'package:Photos/settings/pages/settings_tab_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Login/providers/auth_provider.dart';
import '../auto_upload_provider.dart';
import '../home/providers/drive_file_provider.dart';
import 'dashboard_provider.dart';
import 'widgets/top_bar_desktop.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> tabs = [PhotosTabDesktop(), PhotosTabDesktop(), SettingsTabDesktop()];

  Timer? _autoUploadTimer;
  Timer? _refreshTokenTimer;
  @override
  void initState() {
    initialiseData();
    super.initState();
  }
  Future<void> initialiseData() async {
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshAccessTokens();
    await fileProvider.getStorage();
    startAutoUploadTimer();
    refreshTokenTimer();
  }

  void startAutoUploadTimer() {
    _autoUploadTimer?.cancel();
    _autoUploadTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
      final autoUploadProvider = Provider.of<AutoUploadProvider>(context, listen: false);
      final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
      await fileProvider.syncFilesWithDrive();
      await autoUploadProvider.uploadCameraFiles();
    });
  }

  void refreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = Timer.periodic(Duration(minutes: 50), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshAccessTokens();
    });
  }

  @override
  void dispose() {
    _autoUploadTimer?.cancel();
    _refreshTokenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final px1200 = size.width <1200;
    final px600 = size.width <600;
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFf0f4f9),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Consumer<DriveFileProvider>(
                builder: (context, fileProvider, child) {
                  return fileProvider.selectedFileIds.isNotEmpty? ActionButtonDesktop(selectedFiles: fileProvider.selectedFiles.length,):TopBarDesktop();
                },
              )
          ),
          body: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Row(
                children: [
                  if(!px600)
                    Sidebar(),
                  Consumer<DashboardProvider>(
                    builder: (context, dashboardProvider, child) {
                      return Expanded(child: tabs[dashboardProvider.currentIndex]);
                    },
                  ),
                ],
              ),
              UploadStatusDialog(),
            ],
          ),
          floatingActionButton: px600? Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                width: 250,
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    customStyledNavButton(0, "Photos", Icons.photo_outlined),
                    customStyledNavButton(1, "Albums", Icons.photo_album_outlined),
                    customStyledNavButton(2, "Settings", Icons.settings),
                  ],
                ),
              ),
      
            ),
          ): SizedBox.shrink(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget customStyledNavButton(int ind, String text, IconData icon){
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    return NavButton(
      onTap: (){
        HapticFeedback.lightImpact();
        dashboardProvider.setCurrentIndex(ind);
      },
      isActive: dashboardProvider.currentIndex==ind, text: text,textSize: 16, icon: icon, iconSize: 20, curve: Curves.easeIn,);
  }
}



