import 'package:flutter/material.dart';
import 'colorscheme.dart';
import 'padding.dart';
import 'buttons.dart';
import 'map.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: context.cs.surface,
    //   body: Center(child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       PrimaryButton(
    //         'start',
    //         onPressed: (){},
    //       ),
    //       VPadding(50),
    //       SecondaryButton(
    //         'enter address manually',
    //         onPressed: (){},
    //       )
    //     ],
    //   )),
    // );
    return Scaffold(
      body: Center(
        child: Map()
      ),
    );
  }
}