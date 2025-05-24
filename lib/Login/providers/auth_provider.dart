import 'dart:convert';
import 'package:Photos/services/files_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../const.dart';
import '../../main.dart';
import '../models/UserModel.dart';
import '../services/login_services.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier{
  UserModel? savedUser;
  String get folderId => savedUser?.sharedFolderId ?? '';
  String token = '';
  // bool isLoggedIn = false;
  bool isLoading = false;
  bool isUserExist = false;
  TextEditingController emailController = TextEditingController();
  String get email => emailController.text.replaceAll(' ', '').toLowerCase();
  String otp = '';
  List<String> refreshTokensList = ['', '', '', ''];
  List<String> get emailAccounts=> savedUser?.accounts ?? ['', '', '', ''];
  List<String> accessTokensList = ['', '', '', ''];

  Future<int> sendOTP(BuildContext context) async {
    if(!emailRegex.hasMatch(email)){
      return 402;
    }
    isLoading=true;
    notifyListeners();
    int statusCode = await LoginServices.sendOTP(email, context);
    isLoading=false;
    notifyListeners();
    return statusCode;
  }

  Future<void> handleLogin(BuildContext context) async {
    if(email.isEmpty) {
      errorSnackMsg('Please enter email', context);
      return;
    }
    Response? response= await LoginServices.loginUser(email, '', otp);
    if(response == null) {
      errorSnackMsg('Unable to connect to server', context);
      return;
    }
    int statusCode = response.statusCode;
    if(statusCode == 200 || statusCode == 201) {
      final data = json.decode(response.body);
      final user = data['user'];
      token  = data['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      prefs.setString('emailId', email);
      savedUser = UserModel.fromJson(user);
      // isLoggedIn = true;
      otp = '';
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
    }
  }

  void setOtp(String otp) {
    this.otp = otp;
  }

  void setUser(final data){
    savedUser = UserModel.fromJson(data);
    notifyListeners();
  }

  Future<int> checkLogin() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token')??'';
      String emailId = prefs.getString('emailId')??'';
      if(token.isNotEmpty && emailId.isNotEmpty) {
        Response? response = await LoginServices.getUser(emailId);
        if(response == null) {
          return 500;
        }
        else{
          if(response.statusCode == 200) {
            final data = json.decode(response.body);
            dynamic user = data['user'];
            savedUser = UserModel.fromJson(user);
            refreshTokensList = prefs.getStringList('refreshTokensList')??['','','',''];
            notifyListeners();
            debugPrint('sharedFolderId: ${savedUser?.sharedFolderId}');
            debugPrint('Refresh tokens list: $refreshTokensList');
            debugPrint('User accounts: ${savedUser?.accounts}');
            return 200;
          } else if(response.statusCode == 404) {
            isUserExist = false;
            return 404;
          }
        }
      }
      return 401;
    }
    catch (e) {
      debugPrint('Error getting initial link: $e');
      return 500;
    }
  }

  Future<void> addAccountToDB(String email, String accountNo, {String? folderId}) async {
    try{
      final response  = await http.post(
          Uri.parse('$baseUrl/addAccount'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'accountNo': accountNo,
            'user_id': savedUser?.id,
            if(folderId != null) 'folderId': folderId,
          })
      );
      if(response.statusCode == 201){
        debugPrint('Account added successfully to DB for $email');
        final data = json.decode(response.body);
        final user = data['user'];
        savedUser = UserModel.fromJson(user);
      } else {
        debugPrint('Error adding account: ${response.statusCode}');
      }
    }catch(e){
      debugPrint('Error adding account: $e');
    }
  }

  Future<void> addAccount(String email, String accountNo, String refreshToken, {String? folderId, String? accessToken}) async {
    try{
      int accountNumber = int.parse(accountNo.replaceAll('account', ''));
      if(savedUser!.accounts[accountNumber-1].isNotEmpty && folderId==null) {
        debugPrint('Account already exists in DB');
      }else{
        await addAccountToDB(email, accountNo, folderId: folderId);
      }

      if(folderId==null && accessToken!= null) {
        await FileServices.shareFolderWithEditor(folderId: savedUser!.sharedFolderId, gmailAddress: email, accessToken: accessToken);
      }
      refreshTokensList[accountNumber-1] = refreshToken;
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('refreshTokensList', refreshTokensList);
    }catch(e){
      debugPrint('Error getting initial link: $e');
    }
  }

  Future<void> refreshAccessTokens() async {
    for(int i=0; i<4; i++){
      if(refreshTokensList[i].isNotEmpty){
        String accessToken  = await LoginServices.getAccessTokenFromBackend(refreshTokensList[i]);
        debugPrint('Fetched access token for account ${i+1}');
        accessTokensList[i] = accessToken;
      }
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}