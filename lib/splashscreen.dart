import 'package:Photos/Login/pages/login_page.dart';
import 'package:Photos/dashboard/dashboard.dart';
import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login/providers/auth_provider.dart';
import 'Login/services/login_services.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      checkLogin();
      _initialized = true;
    }
  }



  Future<void> checkLogin() async {
    try{
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int statusCode = await authProvider.checkLogin();
      if(statusCode==200){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
      }else if(statusCode==404){
        errorSnackMsg('User not found', context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      } else if(statusCode==401){
        errorSnackMsg('Invalid credentials', context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      } else{
        errorSnackMsg('Unable to connect to server', context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      }
    }
    catch (e) {
      debugPrint('Error getting initial link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const CircularProgressIndicator(color: Colors.blue,),
      ),
    );
  }
}
