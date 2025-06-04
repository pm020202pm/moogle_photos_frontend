import 'package:Photos/dashboard/widgets/profile_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/drive_file_provider.dart';
import '../dashboard_provider.dart';
import 'upload_icon.dart';
class TopBarDesktop extends StatelessWidget {
  const TopBarDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final fileProvider = Provider.of<DriveFileProvider>(context);
    Size size = MediaQuery.of(context).size;
    final px1200 = size.width <1200;
    final px600 = size.width <600;
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: px600? Colors.white:Color(0xFFf0f4f9),
      child: Row(
        children: [
          Text('Google Photos', style: TextStyle(fontSize: px600? 19:22, fontWeight: FontWeight.bold)),
          if(!px600)
          const SizedBox(width: 95),
          if(px600 || px1200)
            Spacer(),
          if(!px600 && !px1200)
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search your photos and albums',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Color(0xFFe9eef6),
              ),
            ),
          ),
          if(px1200)
          if(!px600)
          const SizedBox(width: 10),
          IconButton(
            icon: dashboardProvider.isRefreshing? SizedBox(width:15, height:15,child: CircularProgressIndicator(strokeWidth: 2,)):const Icon(Icons.refresh),
            onPressed: () async {
              dashboardProvider.setRefreshing(true);
              await fileProvider.loadFilesFromDrive(isInitialLoad: true);
              dashboardProvider.setRefreshing(false);
            },
          ),
          UploadIcon(),
          // IconButton(icon: Icon(Icons.help_outline), onPressed: () {}),
          if(!px600)
          Container(
            decoration: BoxDecoration(
              color: dashboardProvider.currentIndex==1? Colors.grey.shade300: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  dashboardProvider.setCurrentIndex(2);
                }),
          ),
          const SizedBox(width: 12),
          ProfileButton()
        ],
      ),
    );
  }
}
