import 'package:flutter/material.dart';
import 'startscreen.dart';
import 'loadingscreen.dart';
import 'resultsscreen.dart';
import 'package:latlong2/latlong.dart';
import 'engine.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LatLng? userPos;
  List<LatLng>? points;

  @override
  Widget build(BuildContext context) {
    if (userPos == null) {
      return StartScreen(onHaveGotUserLocation: (pos) => setState(() => userPos = pos));
    }
    if (points == null) {
      return LoadingScreen(userPos: userPos!, onHaveGotPoints: (points) => setState(() => points = points));
    }
    return ResultsScreen(points: points!, startPos: userPos!);
  }
}