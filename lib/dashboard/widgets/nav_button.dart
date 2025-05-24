import 'dart:math';
import 'package:flutter/material.dart';
import '../../const.dart';
class NavButton extends StatefulWidget {
  const NavButton({super.key, required this.onTap, required this.isActive, required this.text, required this.icon, required this.curve, required this.textSize, required this.iconSize});
  final Function() onTap;
  final bool isActive;
  final String text;
  final IconData icon;
  final Curve curve;
  final double textSize;
  final double iconSize;

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> with TickerProviderStateMixin{
  late bool _expanded;
  late final AnimationController expandController;
  @override
  void initState() {
    super.initState();
    _expanded = widget.isActive;

    expandController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() => setState(() {}));
  }
  @override
  Widget build(BuildContext context) {
    var curveValue = expandController.drive(CurveTween(curve: _expanded ? widget.curve : widget.curve.flipped)).value;
    _expanded = !widget.isActive;
    if (_expanded) {
      expandController.reverse();
    } else {
      expandController.forward();
    }
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: widget.onTap,
        child: AnimatedContainer(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200), // Adjust the duration as needed
          padding: const EdgeInsets.symmetric(vertical:10 , horizontal: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.isActive
                    ? blueColor.withOpacity(0.4)
                    : Colors.grey.withOpacity(0),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],

            color: _expanded
                ? blueColor.withOpacity(0)
                : blueColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Builder(
              builder: (_) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (widget.text != '')
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Align(
                              alignment: Alignment.centerRight,
                              widthFactor: curveValue,
                              child: Opacity(
                                  opacity: _expanded ? pow(expandController.value, 13) as double : expandController.drive(CurveTween(curve: Curves.easeIn)).value,
                                  child: customText(widget.text, widget.textSize, FontWeight.w600, widget.isActive ? darkBlueColor : yellowColor, 1,))),
                        ),
                      Icon(widget.icon, color: widget.isActive ? darkBlueColor: yellowColor, size: widget.iconSize),
                    ],
                  );
              },
            ),
          )
        ),
      ),
    );
  }
}

Widget customText(String text, double fontSize, FontWeight fontWeight, Color color, double? height) {
  return Text(text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFamily: 'GlacialIndifference',
        height: height ?? 1,
      ),
      overflow: TextOverflow.ellipsis);
}
