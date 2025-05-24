import 'package:flutter/material.dart';
class BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const BottomAction({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class BottomActionDesktop extends StatelessWidget {
  final IconData icon;
  const BottomActionDesktop({super.key, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Color(0xFF0b57d0));
  }
}