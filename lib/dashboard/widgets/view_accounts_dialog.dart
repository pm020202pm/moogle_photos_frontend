import 'dart:async';
import 'package:Photos/Login/models/UserModel.dart';
import 'package:Photos/const.dart';
import 'package:Photos/dashboard/widgets/my_button.dart';
import 'package:Photos/services/files_services.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Login/pages/login_page.dart';
import '../../Login/providers/auth_provider.dart';
import '../../Login/services/login_services.dart';
import '../../home/providers/drive_file_provider.dart';
import 'add_account_button.dart';

class ViewAccountsDialog extends StatefulWidget {
  const ViewAccountsDialog({super.key, required this.hidePopup, required this.width});
  final Function() hidePopup;
  final double width;

  @override
  State<ViewAccountsDialog> createState() => _ViewAccountsDialogState();
}

class _ViewAccountsDialogState extends State<ViewAccountsDialog> {
  final double width = 450;
  int accountNo = 1;
  // String emailLinkedToAccount='';
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    _listenDeepLinks();
    super.initState();
  }

  void _listenDeepLinks() {
    try{
      _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
        if (uri.host == 'auth') {
          String? accessToken = uri.queryParameters['accessToken'];
          String? refreshToken = uri.queryParameters['refreshToken'];
          String? emailId = await LoginServices.fetchUserEmail(accessToken!);
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final fileProvider = Provider.of<DriveFileProvider>(context, listen: false);
          String emailLinkedToAccount = authProvider.emailAccounts[accountNo-1];
          if(emailLinkedToAccount.isNotEmpty){
            if(emailLinkedToAccount!=emailId){
              debugPrint('Email linked to account does not match');
              errorSnackMsg('Please login using $emailLinkedToAccount', context);
              return;
            }
          }
          if(emailId!= null && refreshToken!=null) {

            UserModel? user = authProvider.savedUser;
            String folderId = user?.sharedFolderId??'';
            authProvider.accessTokensList[accountNo-1] = accessToken;
            if(accountNo==1 && user!=null){
              if(folderId.isEmpty && user.email.isNotEmpty){
                String folderName = '${user.email}-photos';
                folderId= await FileServices.createDriveFolder(accessToken, folderName)??'';
                authProvider.addAccount(emailId, "account$accountNo", refreshToken, folderId: folderId);
                fileProvider.getStorage();
              }else{
                authProvider.addAccount(emailId, "account$accountNo", refreshToken);
                fileProvider.getStorage();
              }
            }else{
              if(authProvider.accessTokensList[0].isNotEmpty){
                authProvider.addAccount(emailId, "account$accountNo", refreshToken, accessToken: authProvider.accessTokensList[0]);
                fileProvider.getStorage();
              }else{
                errorSnackMsg('Please add account 1 first', context);
              }
            }
          }else{
            debugPrint('Error fetching email or refresh token');
          }
        }
      });
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }
  }

  @override
  void dispose() {
    _linkSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    String account1= authProvider.emailAccounts[0].isNotEmpty? authProvider.emailAccounts[0] : 'Add Account 1';
    String account2= authProvider.emailAccounts[1].isNotEmpty? authProvider.emailAccounts[1] : 'Add Account 2';
    String account3= authProvider.emailAccounts[2].isNotEmpty? authProvider.emailAccounts[2] : 'Add Account 3';
    String account4= authProvider.emailAccounts[3].isNotEmpty? authProvider.emailAccounts[3] : 'Add Account 4';
    final String emailInitial = authProvider.savedUser?.email[0]??'';
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: width,
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Color(0xFFe9eef6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(authProvider.savedUser!.email, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              width: 80,
              height: 80,
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
              child: Text(emailInitial.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold) ),
            ),
            SizedBox(height: 10),
            AddAccountButton(label: account1, onPressed: () async {
              accountNo=1;
             handleAccountLinking();
            }, accountNo: 1),
            AddAccountButton(label: account2, onPressed: () async {
              accountNo=2;
              handleAccountLinking();
            }, accountNo: 2),
            AddAccountButton(label: account3, onPressed: () async {
              accountNo=3;
              handleAccountLinking();
            }, accountNo: 3),
            AddAccountButton(label: account4, onPressed: () async {
              accountNo=4;
              handleAccountLinking();
            }, accountNo: 4),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyButton(
                    bgColor: Colors.white,
                    borderRadius: [30, 2, 30, 2],
                    padding: [25,20],
                    onPressed: (){
                      int accountCount = authProvider.emailAccounts.where((email) => email.isNotEmpty).length;
                      if(accountCount>=4){
                        errorSnackMsg('You can only add 4 accounts', context);
                      }else{
                        for(int i=0; i<4; i++){
                          if(authProvider.emailAccounts[i].isEmpty){
                            accountNo = i+1;
                            handleAccountLinking();
                            break;
                          }
                        }
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFe9eef6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.add, color: Color(0xFF004bcd), size: 20)
                        ),
                        SizedBox(width: 6),
                        Text('Add account', style: TextStyle(color: Colors.black, fontSize: 15),),
                      ],
                    ),
                ),
                const SizedBox(width: 4),
                MyButton(
                  bgColor: Colors.white,
                  borderRadius: [2, 30, 2, 30],
                  padding: [25,20],
                  onPressed: () async {
                    widget.hidePopup();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, size: 20,),
                      SizedBox(width: 6),
                      Text('Sign out     ', style: TextStyle(color: Colors.black, fontSize: 15),),
                    ],
                  ),
                ),

                // bottomButton('Sign out', Icon(Icons.logout_rounded, size: 16,)),
              ],
            ),

            // Divider(),
            // Row(
            //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     TextButton(onPressed: () async {
            //       widget.hidePopup();
            //       SharedPreferences prefs = await SharedPreferences.getInstance();
            //       await prefs.clear();
            //       Navigator.pushAndRemoveUntil(
            //         context,
            //         MaterialPageRoute(builder: (context) => const LoginPage()),
            //             (route) => false,
            //       );
            //     }, child: Text("Sign out")),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  void handleAccountLinking() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if(authProvider.refreshTokensList[accountNo-1].isEmpty){
      if(accountNo!=1 && authProvider.refreshTokensList[0].isEmpty){
        errorSnackMsg('Please add account 1 first', context);
        return;
      }
      final Uri loginUri = Uri.parse(authUrl);
      await launchUrl(loginUri, mode: LaunchMode.externalApplication);
    }else{
      errorSnackMsg('Account already linked', context);
    }
  }

  Widget bottomButton(String label, Widget icon){
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFFffffff),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.black, fontSize: 12),),
        ],
      ),
    );
  }
}
