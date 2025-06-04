import 'package:Photos/dashboard/widgets/view_accounts_dialog_mobile.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../Login/providers/auth_provider.dart';
import '../../auto_upload_provider.dart';
import 'view_accounts_dialog.dart';
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final autoUploadProvider = Provider.of<AutoUploadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String emailInitial = authProvider.savedUser?.email[0]??'';
    Size size = MediaQuery.of(context).size;
    final px1200 = size.width <1200;
    final px600 = size.width <600;
    return InkWell(
      onTap: () {
        showPopover(
          backgroundColor: Colors.transparent,
          barrierColor: Colors.transparent,
          shadow: const [BoxShadow(color: Colors.transparent, blurRadius: 5)],
          radius: 30,
          arrowHeight: 0,
          arrowWidth: 0,
          context: context,
          bodyBuilder: (context) => Padding(
            padding: const EdgeInsets.all(12),
            child: px600
                ? ViewAccountsDialogMobile(hidePopup: () {Navigator.pop(context);},  width: 400)
                :ViewAccountsDialog(
                hidePopup: () {Navigator.pop(context);},
                width: 400),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(emailInitial.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold) ),
          ),
          if(autoUploadProvider.isAutoUploading)
          CircularProgressIndicator(color: Colors.blue.shade900, strokeWidth: 2),
        ],
      ),
    );
  }
}