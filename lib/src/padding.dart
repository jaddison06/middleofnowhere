import 'package:flutter/material.dart';

class VPadding extends StatelessWidget {
  final double height;
  const VPadding(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height),
    );
  }
}

class HPadding extends StatelessWidget {
  final double width;
  const HPadding(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width),
    );
  }
}