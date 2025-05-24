import 'package:flutter/material.dart';
class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onPressed, required this.child, this.padding=const [4,4], this.bgColor=Colors.transparent, this.elevation=0, this.overlayColor=Colors.grey, this.borderRadius=const [20, 20, 20, 20]});
  final Function() onPressed;
  final Widget child;
  final List<double> padding;
  final Color bgColor;
  final double elevation;
  final List<double> borderRadius;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: padding[0], horizontal:padding[0] ),
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(borderRadius[0]), topRight: Radius.circular(borderRadius[1]), bottomLeft: Radius.circular(borderRadius[2]), bottomRight: Radius.circular(borderRadius[3])),
            ),
            elevation: elevation,
            shadowColor: Colors.transparent,
            overlayColor: overlayColor
        ),
        child: child
    );
  }
}
