import 'package:flutter/material.dart';

class FutureWithDefault extends StatelessWidget {
  final Future<Widget> Function() builder;
  final Widget show;

  const FutureWithDefault({super.key, required this.builder, this.show = const CircularProgressIndicator()});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: builder(),
      builder: (_, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.requireData;
        } else {
          return show;
        }
      },
    );
  }
}