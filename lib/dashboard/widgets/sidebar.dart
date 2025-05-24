import 'package:Photos/dashboard/dashboard_provider.dart';
import 'package:Photos/dashboard/widgets/my_button.dart';
import 'package:Photos/home/providers/drive_file_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final px1200 = size.width <1200;
    final px600 = size.width <600;
    return Container(
      width: px1200? 76:270,
      color: Color(0xFFf0f4f9),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            SidebarButton(index: 0, label: px1200? '':'Photo', icon: Icons.photo_outlined),
            SidebarButton(index: 1, label: px1200? '':'Albums', icon: Icons.photo_album_outlined),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Consumer<DriveFileProvider>(
              builder: (context, fileProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: (fileProvider.usedStorage==0 && fileProvider.totalStorage==1)
                          ? LinearProgressIndicator(value: null, minHeight: 6)
                          : LinearProgressIndicator(value: fileProvider.usedStorage / fileProvider.totalStorage, minHeight: 6),
                    ),
                    const SizedBox(height: 4),
                    (fileProvider.usedStorage==0 && fileProvider.totalStorage==1)
                        ? Text("Getting storage info...", style: TextStyle(fontSize: 12))
                        : Text("${fileProvider.usedStorage.toStringAsFixed(1)} GB of ${fileProvider.totalStorage.toStringAsFixed(0)} GB used", style: TextStyle(fontSize: 12)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget sidebarItem(IconData icon, String label, Function() onTap, {bool isSelected = false}) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(30),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: ListTile(
  //         selected: isSelected,
  //         selectedColor: Color(0xFF001d35),
  //         selectedTileColor: Color(0xFFc2e7ff),
  //         leading: Icon(icon),
  //         title: Text(label,),
  //         onTap: (){
  //           onTap();
  //         }, // Hook up your logic
  //       ),
  //     ),
  //   );
  // }
}

class SidebarButton extends StatelessWidget {
  const SidebarButton({super.key, required this.index, required this.label, required this.icon});
  final int index;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (BuildContext context, dashboardProvider, Widget? child) {
        return MyButton(
            padding: const [16, 0],
            borderRadius: [40, 40, 40, 40],
            bgColor: dashboardProvider.currentIndex==index? Color(0xFFc2e7ff): Colors.transparent,
            onPressed: (){
              dashboardProvider.setCurrentIndex(index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: dashboardProvider.currentIndex==index? Color(0xFF001d35): Colors.black, size: 24),
                if(label.isNotEmpty)
                const SizedBox(width: 10),
                if(label.isNotEmpty)
                Text(label, style: TextStyle(color: dashboardProvider.currentIndex==index? Color(0xFF001d35): Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),
              ],
            )
        );
      },
    );
  }
}



// ClipRRect(
// borderRadius: BorderRadius.circular(30),
// child: Material(
// color: Colors.transparent,
// child: ListTile(
// selected: dashboardProvider.currentIndex==index,
// selectedColor: Color(0xFF001d35),
// selectedTileColor: Color(0xFFc2e7ff),
// leading: Icon(icon),
// title: Text(label,),
// onTap: (){
// dashboardProvider.setCurrentIndex(index);
// }, // Hook up your logic
// ),
// ),
// );