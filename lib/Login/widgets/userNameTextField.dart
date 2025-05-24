import 'package:flutter/material.dart';
class UserNameTextField extends StatelessWidget {
  const UserNameTextField({super.key, required this.userNameController});
  final TextEditingController userNameController;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: TextField(
        controller: userNameController,
        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your email',
          hintStyle: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
