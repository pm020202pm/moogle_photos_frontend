import 'package:Photos/Login/pages/opt_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import '../providers/auth_provider.dart';
import '../services/login_services.dart';
import '../widgets/userNameTextField.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor:  Colors.white,
      body: Center(
        child: Container(
          width: 350,
          height: 400,
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(80),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(50),
              )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),),
                    Text('Login back to your account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.grey.shade50),),
                  ],
                ),
                UserNameTextField(userNameController: authProvider.emailController),
                authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white,)
                    : Button(buttonText: "Send OTP", textColor: Colors.black, buttonBgColor: Colors.white,
                  onPressed:() async {
                    handleLogin(context, authProvider);
                  },
                  height: 60,
                  width: 320,
                  borderRadius: 30,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleLogin(BuildContext context, AuthProvider authProvider) async {
    int statusCode = await authProvider.sendOTP(context);
    if(statusCode == 200) {
      successSnackMsg('OTP sent successfully', context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=> OtpPage()));
    } else if (statusCode == 402) {
      errorSnackMsg('Enter valid email', context);
    } else if (statusCode == 404) {
      errorSnackMsg('You are not an authentic user', context);
    } else {
      errorSnackMsg('Unable to complete action. Please try again.', context);
    }
  }
}
