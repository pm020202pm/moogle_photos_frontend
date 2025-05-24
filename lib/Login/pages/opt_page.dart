import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/login_services.dart';
import '../widgets/otpField.dart';
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey.shade50),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text('Please enter OTP received via email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.grey.shade50),),
                OTPField(onOTPChange: (val){
                  authProvider.setOtp(val);
                  if(val.length==4) {
                    authProvider.handleLogin(context);
                  }
                }),
                TextButton(
                  onPressed: () async {
                    int statusCode = await authProvider.sendOTP(context);
                    if(statusCode == 200) {
                      successSnackMsg('OTP sent successfully', context);
                    } else if (statusCode == 402) {
                      errorSnackMsg('Error in sending OTP', context);
                    }  else if (statusCode == 404) {
                      errorSnackMsg('You are not an authentic user', context);
                    } else {
                      errorSnackMsg('Unable to complete action. Please try again.', context);
                    }
                    },
                  child: Text("Resend OTP", style: TextStyle(color: Colors.blue.shade100),),
                ),
                const SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
