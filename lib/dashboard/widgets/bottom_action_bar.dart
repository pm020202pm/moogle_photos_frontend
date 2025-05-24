import 'package:Photos/Login/providers/auth_provider.dart';
import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Login/services/login_services.dart';
import 'bottom_sheet_button.dart';
import '../../home/providers/drive_file_provider.dart';
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                BottomAction(icon: Icons.share, label: 'Share'),
                BottomAction(icon: Icons.add, label: 'Add to'),
                DeleteButton(),
                BottomAction(icon: Icons.star_border, label: 'Favourite'),
                BottomAction(icon: Icons.archive, label: 'Archive'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return InkWell(
      onTap: () async {
        // String accessToken = await LoginServices.getAccessTokenFromBackend(authProvider.refreshTokens['account1']??'');
        // for (var file in fileProvider.selectedFiles) {
        //   final success = await FileServices.deleteFileFromDrive(accessToken, file.id);
        //   if (success) fileProvider.removeFile(file.id);
        // }
        // fileProvider.clearSelection();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white),
          const SizedBox(height: 6),
          Text('Bin', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}


class DeleteButtonDesktop extends StatelessWidget {
  const DeleteButtonDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return InkWell(
      onTap: () async {
        for (var file in fileProvider.selectedFiles) {
          String ownerEmail = file.ownerEmail;
          int ind = authProvider.savedUser!.accounts.indexOf(ownerEmail);
          if (ind == -1) {
            errorSnackMsg('File owner is $ownerEmail', context);
            continue;
          }else{
            if(authProvider.accessTokensList[ind].isEmpty){
              errorSnackMsg('Invalid access token for account ${ind+1}', context);
              continue;
            }
            final success = await FileServices.deleteFileFromDrive(authProvider.accessTokensList[ind], file.id);
            if (success) {
              fileProvider.removeFile(file.id);
            }else{
              errorSnackMsg('Failed to delete file ${file.name}', context);
            }
          }
        }
        fileProvider.clearSelection();
      },
      child: Icon(Icons.delete_outline_rounded, color: Color(0xFF0b57d0)),
    );
  }
}

