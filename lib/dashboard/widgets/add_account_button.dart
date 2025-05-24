import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Login/providers/auth_provider.dart';

class AddAccountButton extends StatelessWidget {
  const AddAccountButton({super.key, required this.label, required this.onPressed, required this.accountNo});
  final String label;
  final Function() onPressed;
  final int accountNo;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    String emailLinked = authProvider.emailAccounts[accountNo-1];
    bool isError = authProvider.refreshTokensList[accountNo-1] == '' && emailLinked!='';
    bool isAllComplete = authProvider.accessTokensList[accountNo-1] != '' && emailLinked!='';
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        height: 50,
        decoration: BoxDecoration(
          color: (isAllComplete)? Colors.green.shade50:Colors.grey.shade100,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: isAllComplete? Colors.green.shade500:Colors.grey.shade300),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(emailLinked!='')
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
            if(emailLinked!='')
            const Spacer(),
            if(emailLinked=='')
            ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(4),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.transparent
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_sharp, color: Colors.green, size: 16),
                    const SizedBox(width: 3),
                    Text('Add a google account', style: TextStyle(fontSize: 12, color: Colors.green),)
                  ],
                )
            ),
            if(isError)
            ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.red),
                  ),
                  elevation: 0
                ),
                child:
                Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 3),
                      Text('Link with google', style: TextStyle(fontSize: 8, color: Colors.red),)
                    ],
                  )
            ),
          ],
        ),
      ),
    );
  }
}
