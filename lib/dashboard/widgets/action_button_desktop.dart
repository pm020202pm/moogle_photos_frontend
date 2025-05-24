import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_action_bar.dart';
import 'bottom_sheet_button.dart';
import '../../home/providers/drive_file_provider.dart';

class ActionButtonDesktop extends StatelessWidget {
  const ActionButtonDesktop({super.key, required this.selectedFiles});
  final int selectedFiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color(0xFFf0f4f9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 10),
            child: IconButton(onPressed: (){
              final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
              fileProvider.clearSelection();
            }, icon: Icon(Icons.close, color: Colors.black,)),
          ),
          Text('$selectedFiles selected', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          Spacer(),
          BottomActionDesktop(icon: Icons.share_outlined),
          SizedBox(width: 16),
          BottomActionDesktop(icon: Icons.add),
          SizedBox(width: 16),
          DeleteButtonDesktop(),
        ],
      ),
    );
  }
}